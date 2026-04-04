extends Object
# Replaces ElectricShock._physics_process() with an optimised version:
#   1. O(1) Dictionary hit-set instead of the vanilla O(n) Array linear scan.
#      The vanilla `not in _tiles_hit_all` scans the entire already-hit array for
#      every neighbour of every frontier tile — O(n²) total across the chain.
#   2. Inlined 4-neighbour checks — removes the per-frontier-tile Array alloc.
#   3. Visual arc cap — skips draw_electricity() once the configured threshold is
#      reached, bounding GPU cost from accumulated ShaderMaterial Sprite2Ds without
#      affecting damage at all.
#
# Fully supersedes both the vanilla method and game_limits_mod's electric_shock
# hook.  Both caps are read from game_limits_mod config when present; GDScript
# resource caching means the load() call costs only a dict lookup per frame.

const LOG_NAME := "der_floh-performance_mod:ElectricShockHook"

# Per-instance O(1) membership set, keyed by ElectricShock.get_instance_id().
# Lazily seeded on the first _physics_process frame; erased when the chain ends
# to prevent a memory leak from instances that never reach end().
static var _hit_sets: Dictionary = {}


func _physics_process(chain: ModLoaderHookChain, _delta: float) -> void:
	var self_obj := chain.reference_object as ElectricShock
	var iid: int   = self_obj.get_instance_id()

	# Seed the hit-set from _tiles_hit_all on the very first frame.
	# Vanilla _ready adds the initial tile only to _tiles_hit_current, not to
	# _tiles_hit_all, so the set starts empty — matching vanilla's double-hit
	# behaviour for the initial tile.
	if not _hit_sets.has(iid):
		var seed_set: Dictionary = {}
		for t: Vector2i in self_obj._tiles_hit_all:
			seed_set[t] = true
		_hit_sets[iid] = seed_set

	var hit_set: Dictionary = _hit_sets[iid]

	# Read caps from game_limits_mod config; fall back to vanilla/perf defaults.
	var limits_script = load("res://mods-unpacked/der_floh-game_limits_mod/mod_main.gd")
	var max_tiles:   int = 500
	var max_visuals: int = 200
	if limits_script != null:
		max_tiles   = limits_script.get_max_electric_chain()
		max_visuals = limits_script.get_max_electric_visuals()

	var new_tiles_hit_current: Array[Vector2i] = []
	for tile: Vector2i in self_obj._tiles_hit_current:
		# Inline all 4 neighbours — avoids a typed Array allocation per frontier tile.
		var n: Vector2i

		n = tile + Vector2i(1, 0)
		if self_obj.tilemap.get_tile_enum(n) == self_obj._tile_name and not hit_set.has(n):
			new_tiles_hit_current.append(n)
			self_obj._tiles_hit_all.append(n)
			hit_set[n] = true
			if hit_set.size() <= max_visuals:
				self_obj.draw_electricity(tile, 0)

		n = tile + Vector2i(0, 1)
		if self_obj.tilemap.get_tile_enum(n) == self_obj._tile_name and not hit_set.has(n):
			new_tiles_hit_current.append(n)
			self_obj._tiles_hit_all.append(n)
			hit_set[n] = true
			if hit_set.size() <= max_visuals:
				self_obj.draw_electricity(tile, 1)

		n = tile + Vector2i(-1, 0)
		if self_obj.tilemap.get_tile_enum(n) == self_obj._tile_name and not hit_set.has(n):
			new_tiles_hit_current.append(n)
			self_obj._tiles_hit_all.append(n)
			hit_set[n] = true
			if hit_set.size() <= max_visuals:
				self_obj.draw_electricity(tile, 2)

		n = tile + Vector2i(0, -1)
		if self_obj.tilemap.get_tile_enum(n) == self_obj._tile_name and not hit_set.has(n):
			new_tiles_hit_current.append(n)
			self_obj._tiles_hit_all.append(n)
			hit_set[n] = true
			if hit_set.size() <= max_visuals:
				self_obj.draw_electricity(tile, 3)

	if new_tiles_hit_current.is_empty() or self_obj._current_damage == 0 \
			or hit_set.size() > max_tiles:
		_hit_sets.erase(iid)  # clean up before end() to prevent memory leak
		self_obj.end()
	else:
		self_obj._tiles_hit_current = new_tiles_hit_current
		self_obj.damage_current_tiles()
		self_obj._current_damage = self_obj._current_damage * self_obj.damage_ratio
		self_obj.lightning_audio.volume_db = min(14, self_obj.lightning_audio.volume_db + 1.0)
		self_obj.lightning_audio.pitch_scale = max(0.1, self_obj.lightning_audio.pitch_scale - 0.03)
	# chain.execute_next() intentionally omitted — fully supersedes vanilla + game_limits_mod hook.
