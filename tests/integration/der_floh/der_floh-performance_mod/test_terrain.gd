extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# The faster terrain generation builds exactly the chunks vanilla builds, on every map type.
# Vanilla's generate_chunk stays callable as the renamed vanilla_<hash>_generate_chunk the hook wraps.

const HOOK_PATH := "res://mods-unpacked/der_floh-performance_mod/extensions/scenes/tilemaps/tile_map_chunk.hooks.gd"
const SAMPLE_CHUNKS := [Vector2i(0, -2), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-2, 3), Vector2i(5, 9)]
const MAP_LEVELS := 7
const NOISE_SEED := 4711


func test_terrain_matches_vanilla_on_every_map() -> void:
	if not await in_mine():
		return
	var tm = tilemap()
	var hook = load(HOOK_PATH).new()
	var probe = TileMapManager.TILE_MAP_CHUNK.instantiate()
	var vanilla := _vanilla_methods(probe)
	use_value(gvars, "level", gvars.level)
	var timings := [0, 0]
	for level in MAP_LEVELS:
		gvars.level = level
		var differences := 0
		for chunk_id in SAMPLE_CHUNKS:
			var fast = _new_chunk(chunk_id, tm.chunk_size)
			var plain = _new_chunk(chunk_id, tm.chunk_size)
			seed(NOISE_SEED)
			var started := Time.get_ticks_usec()
			hook.generate_chunk(ModLoaderHookChain.new(fast, [Callable(fast, vanilla["generate_chunk"])]), tm.noise)
			timings[0] += Time.get_ticks_usec() - started
			seed(NOISE_SEED)
			started = Time.get_ticks_usec()
			plain.call(vanilla["generate_chunk"], tm.noise)
			timings[1] += Time.get_ticks_usec() - started
			differences += _differences(fast, plain)
			fast.free()
			plain.free()
		expect_eq(differences, 0, "tiles differing from vanilla on map level %d" % level)
	var funnel_mismatches := range(-300, 330).filter(func(x: int) -> bool: return probe.lvl_from_global_pos_TIGHTFUNNEL(Vector2i(x, 5)) != probe.call(vanilla["lvl_from_global_pos_TIGHTFUNNEL"], Vector2i(x, 5))).size()
	expect_eq(funnel_mismatches, 0, "Tight Funnel layer lookups differing from vanilla")
	expect(timings[0] < timings[1], "faster than vanilla: %d µs vs %d µs" % timings)
	probe.free()
	hook.free()


static func _vanilla_methods(chunk) -> Dictionary:
	var methods := {}
	for method in chunk.get_method_list():
		var name: String = method.name
		if name.begins_with("vanilla_"):
			methods[name.substr(name.find("_", 8) + 1)] = name
	return methods


static func _new_chunk(chunk_id: Vector2i, chunk_size: int):
	var chunk = TileMapManager.TILE_MAP_CHUNK.instantiate()
	chunk.chunk_id = chunk_id
	chunk.chunk_size = chunk_size
	return chunk


static func _differences(fast, plain) -> int:
	var count := 0
	for i in fast.tiles.size():
		var cell: Vector2i = fast.array_to_pos(i)
		if fast.tiles[i] != plain.tiles[i] or fast.tiles_health[i] != plain.tiles_health[i] \
				or fast.get_cell_atlas_coords(cell) != plain.get_cell_atlas_coords(cell) \
				or fast.get_cell_alternative_tile(cell) != plain.get_cell_alternative_tile(cell):
			count += 1
	return count
