extends Object
# Fully replaces TileMapManager.load_chunks() so the chunk load radius and the
# number of chunks generated per frame use user-configured values instead of
# the hardcoded range(-3, 4) = ±3 and the hardcoded 1 chunk/frame.
# The inner LIVE zone (full collision) remains at ±1 (3×3 chunks) regardless of
# the configured radius — only the outer NO_COLLISIONS ring is extended.

const LOG_NAME := "der_floh-game_limits_mod:ChunkHook"


func load_chunks(chain: ModLoaderHookChain) -> void:
	var tm := chain.reference_object as TileMapManager

	var mod_main = load("res://mods-unpacked/der_floh-game_limits_mod/mod_main.gd")
	if not mod_main.get_enabled():
		chain.execute_next()
		return

	var r: int = mod_main.get_chunk_load_radius()
	var chunks_per_frame: int = mod_main.get_chunks_per_frame()

	var chunkloaders: Array = tm.get_tree().get_nodes_in_group("chunkloaders")
	tm.live_chunks = {}
	tm.simple_collision_chunks = {}

	# Deduplicate: multiple entities in the same chunk should only expand the zone once.
	var central_chunk_ids: Dictionary = {}
	for chunkloader in chunkloaders:
		var chunk_id: Vector2i = tm.get_chunk_id_pos(chunkloader.global_position)
		if not central_chunk_ids.has(chunk_id):
			central_chunk_ids[chunk_id] = true

	for chunk_id in central_chunk_ids.keys():
		for x in range(-r, r + 1):  # r comes from user config (default 3 = vanilla ±3)
			for y in range(-r, r + 1):
				var chunk_id_xy := Vector2i(chunk_id.x + x, chunk_id.y + y)
				tm.add_chunk_to_load_queue(chunk_id_xy)  # no-op if already created or already queued

				# Inner ±1 zone → LIVE (full tiles + collision)
				if abs(x) < 2 and abs(y) < 2:
					tm.simple_collision_chunks.erase(chunk_id_xy)
					tm.live_chunks[chunk_id_xy] = true
				else:
					# Outer ring → NO_COLLISIONS (visible, no physics)
					tm.simple_collision_chunks[chunk_id_xy] = true

	for chunk_id in tm.chunks_created.keys():
		if chunk_id in tm.live_chunks:
			if tm.chunks_created[chunk_id].state != TileMapChunk.States.LIVE:
				tm.chunks_created[chunk_id].change_state(TileMapChunk.States.LIVE)
		elif chunk_id in tm.simple_collision_chunks:
			if tm.chunks_created[chunk_id].state != TileMapChunk.States.NO_COLLISIONS:
				tm.chunks_created[chunk_id].change_state(TileMapChunk.States.NO_COLLISIONS)
		else:
			if tm.chunks_created[chunk_id].state != TileMapChunk.States.DISABLED:
				tm.chunks_created[chunk_id].change_state(TileMapChunk.States.DISABLED)

	for _i in range(chunks_per_frame):
		tm.load_next_unloaded_chunk()
	tm.change_next_chunk_state()
	# chain.execute_next() intentionally omitted — this fully replaces vanilla
