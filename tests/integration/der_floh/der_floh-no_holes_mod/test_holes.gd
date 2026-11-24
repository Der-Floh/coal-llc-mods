extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Underground holes are filled, Sparse maps included; only the chest rooms' centers stay open.

const SKY_LEVELS := ["SKY_MINE", "SPARSE_SKY_MINE"]
const SETTLE_FRAMES := 120
# Sky mines are built upwards from this row.
const SKY_GROUND_ROW := -10


func test_standard_mine_has_no_holes() -> void:
	if await fresh_mine():
		await frames(SETTLE_FRAMES)
		expect_eq(_holes(false), [], "open underground tiles")


func test_sparse_mine_has_no_holes() -> void:
	if await fresh_mine(DEFAULT_PROFESSION, DEFAULT_MODE, "SPARSE"):
		await frames(SETTLE_FRAMES)
		expect_eq(_holes(false), [], "open underground tiles on a Sparse map")


func _holes(sky: bool) -> Array:
	var tm = tilemap()
	var chest_rooms := {}
	for chunk in tm.chunks_created.values():
		for child in chunk.get_children():
			if child is Chest:
				chest_rooms[chunk.pos_to_global_pos(chunk.local_to_map(child.position))] = true
	var holes := []
	for chunk in tm.chunks_created.values():
		for i in chunk.tiles.size():
			var tile: Vector2i = chunk.array_to_global_pos(i)
			var underground := tile.y <= SKY_GROUND_ROW if sky else tile.y >= 0
			if underground and chunk.tiles[i] == TileMapChunk.Tiles.EMPTY and not chest_rooms.has(tile) and holes.size() < 5:
				holes.append(tile)
	return holes
