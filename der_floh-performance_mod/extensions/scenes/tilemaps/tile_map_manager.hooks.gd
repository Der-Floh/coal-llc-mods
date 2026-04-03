extends Object
# Replaces TileMapManager.load_chunks() and TileMapManager.apply_tile_effects()
# with optimised versions that avoid redundant per-frame work at large chunk radii.
#
# load_chunks():
#   - Skips the zone rebuild entirely when no chunkloader has moved to a new chunk.
#   - Replaces the O(n) chunk_load_queue.has() scan with an O(1) shadow dict.
#   - Supersedes der_floh-game_limits_mod's load_chunks hook (load order guaranteed
#     by folder name: "performance_mod" sorts after "game_limits_mod").
#
# apply_tile_effects():
#   - Iterates chunks_created dict instead of allocating get_children() every tick.
#   - Skips idle outer-ring (NO_COLLISIONS) chunks that have no queued tile work.

const LOG_NAME := "der_floh-performance_mod:Hook"

# Per-TileMapManager-instance tracking, keyed by get_instance_id().
# Persists across frames via static vars.
static var _prev_chunk_ids: Dictionary = {}  # inst_id → Dictionary[Vector2i, bool]
static var _queued_set: Dictionary = {}      # inst_id → Dictionary[Vector2i, bool]
                                             # O(1) shadow of tm.chunk_load_queue


func load_chunks(chain: ModLoaderHookChain) -> void:
	var tm := chain.reference_object as TileMapManager
	var inst_id := tm.get_instance_id()

	# Read config from game_limits_mod when present; fall back to vanilla defaults.
	var r: int = 3
	var chunks_per_frame: int = 1
	var limits_script = load("res://mods-unpacked/der_floh-game_limits_mod/mod_main.gd")
	if limits_script != null:
		r = limits_script.get_chunk_load_radius()
		chunks_per_frame = limits_script.get_chunks_per_frame()

	# Ensure the shadow queue-set exists for this TileMapManager instance.
	if not _queued_set.has(inst_id):
		_queued_set[inst_id] = {}
	var q_set: Dictionary = _queued_set[inst_id]

	# Compute the deduplicated set of chunk-coords occupied by chunkloaders.
	var chunkloaders: Array = tm.get_tree().get_nodes_in_group("chunkloaders")
	var current_ids: Dictionary = {}
	for loader in chunkloaders:
		current_ids[tm.get_chunk_id_pos(loader.global_position)] = true

	# --- Zone rebuild (only when a chunkloader crosses a chunk boundary) ----------
	var prev_ids: Dictionary = _prev_chunk_ids.get(inst_id, {})
	if current_ids != prev_ids:
		tm.live_chunks = {}
		tm.simple_collision_chunks = {}

		# Resync the shadow set from the actual queue so we stay consistent with
		# any chunks that were queued externally (e.g. Bus.load_chunks_around_entity).
		q_set.clear()
		for cid in tm.chunk_load_queue:
			q_set[cid] = true

		for chunk_id in current_ids.keys():
			for x in range(-r, r + 1):
				for y in range(-r, r + 1):
					var cxy := Vector2i(chunk_id.x + x, chunk_id.y + y)

					# Queue missing chunks using the O(1) shadow dict.
					if not tm.chunks_created.has(cxy) and not q_set.has(cxy):
						tm.chunk_load_queue.append(cxy)
						q_set[cxy] = true

					# Zone classification — LIVE takes priority over NO_COLLISIONS.
					if abs(x) < 2 and abs(y) < 2:
						tm.simple_collision_chunks.erase(cxy)
						tm.live_chunks[cxy] = true
					elif not tm.live_chunks.has(cxy):
						tm.simple_collision_chunks[cxy] = true

		# Update chunk states, calling change_state only when actually needed.
		for chunk_id in tm.chunks_created.keys():
			var chunk: TileMapChunk = tm.chunks_created[chunk_id]
			if tm.live_chunks.has(chunk_id):
				if chunk.state != TileMapChunk.States.LIVE:
					chunk.change_state(TileMapChunk.States.LIVE)
			elif tm.simple_collision_chunks.has(chunk_id):
				if chunk.state != TileMapChunk.States.NO_COLLISIONS:
					chunk.change_state(TileMapChunk.States.NO_COLLISIONS)
			else:
				if chunk.state != TileMapChunk.States.DISABLED:
					chunk.change_state(TileMapChunk.States.DISABLED)

		_prev_chunk_ids[inst_id] = current_ids

	# --- Queue consumption (runs every frame regardless of zone dirty state) ------
	for _i in range(chunks_per_frame):
		if not tm.chunk_load_queue.is_empty():
			q_set.erase(tm.chunk_load_queue[0])  # keep shadow set in sync before the entry is removed
		tm.load_next_unloaded_chunk()

	tm.change_next_chunk_state()
	# chain.execute_next() intentionally omitted — fully replaces vanilla + game_limits_mod.


func apply_tile_effects(chain: ModLoaderHookChain) -> void:
	var tm := chain.reference_object as TileMapManager

	tm._tile_flashes = []

	# Iterate the chunks_created dict directly instead of calling get_children(),
	# which allocates a new Array every physics tick.
	for chunk_id in tm.chunks_created.keys():
		var chunk: TileMapChunk = tm.chunks_created[chunk_id]
		match chunk.state:
			TileMapChunk.States.LIVE:
				# Inner zone — always process (player interaction happens here).
				chunk.apply_tile_effects()
			TileMapChunk.States.NO_COLLISIONS:
				# Outer ring — skip idle chunks; only process if something queued work
				# on them (e.g. a bomb blast reached them).
				if not chunk.damage_tiles.is_empty() \
						or not chunk.poison_tiles.is_empty() \
						or not chunk.burn_tiles.is_empty():
					chunk.apply_tile_effects()
			# TileMapChunk.States.DISABLED → invisible and physics-off; skip entirely.

	tm.tile_flashes.flash_tiles(tm._tile_flashes)
	# chain.execute_next() intentionally omitted — fully replaces vanilla.
