extends Object
# Fully replaces ElectricShock._physics_process() so the chain reaction caps at
# the user-configured value instead of the hardcoded MAX_TILES = 500, and limits
# visual arc nodes to the configured max to keep GPU cost bounded.
# When performance_mod is also installed its hook supersedes this one entirely.

const LOG_NAME := "der_floh-game_limits_mod:ElectricShockHook"


func _physics_process(chain: ModLoaderHookChain, _delta: float) -> void:
	var self_obj := chain.reference_object as ElectricShock
	var mod_main = load("res://mods-unpacked/der_floh-game_limits_mod/mod_main.gd")
	if not mod_main.get_enabled():
		chain.execute_next([_delta])
		return

	var max_tiles:   int = mod_main.get_max_electric_chain()
	var max_visuals: int = mod_main.get_max_electric_visuals()

	var new_tiles_hit_current: Array[Vector2i] = []
	for tile in self_obj._tiles_hit_current:
		var surrounding_tiles: Array[Vector2i] = [
			tile + Vector2i(1, 0),
			tile + Vector2i(0, 1),
			tile + Vector2i(-1, 0),
			tile + Vector2i(0, -1),
		]
		for i in len(surrounding_tiles):
			var new_tile: Vector2i = surrounding_tiles[i]
			if (self_obj.tilemap.get_tile_enum(new_tile) == self_obj._tile_name) \
					and (new_tile not in self_obj._tiles_hit_all):
				new_tiles_hit_current.append(new_tile)
				self_obj._tiles_hit_all.append(new_tile)
				# Only spawn visual arcs up to the configured cap; damage is unaffected.
				if self_obj._tiles_hit_all.size() <= max_visuals:
					self_obj.draw_electricity(tile, i)

	if (new_tiles_hit_current == []) or (self_obj._current_damage == 0) \
			or (self_obj._tiles_hit_all.size() > max_tiles):
		if mod_main._debug and self_obj._tiles_hit_all.size() > 0:
			ModLoaderLog.info(
				"ElectricShock ended: total_tiles=%d max_tiles=%d max_visuals=%d" % [
					self_obj._tiles_hit_all.size(), max_tiles, max_visuals
				], LOG_NAME
			)
		self_obj.end()
	else:
		self_obj._tiles_hit_current = new_tiles_hit_current
		self_obj.damage_current_tiles()
		self_obj._current_damage = self_obj._current_damage * self_obj.damage_ratio
		self_obj.lightning_audio.volume_db = min(14, self_obj.lightning_audio.volume_db + 1.0)
		self_obj.lightning_audio.pitch_scale = max(0.1, self_obj.lightning_audio.pitch_scale - 0.03)
	# Vanilla method fully replaced — chain.execute_next() intentionally omitted.
