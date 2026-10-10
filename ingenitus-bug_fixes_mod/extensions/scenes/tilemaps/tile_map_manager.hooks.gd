extends Object

# fix_blast_edges. on_BombExplode and earthquake_pos scan tile rows
# range(ceil(top), floor(bottom)) and columns range(ceil(left), floor(right)).
# range() excludes its end, so the tiles on row floor(bottom) and column
# floor(right) are never tested, even when they are inside the circle: every
# explosion is clipped on its bottom and right side. After vanilla runs, the tiles
# it skipped get the same inside_circle test and the same effect.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-bug_fixes_mod/mod_main.gd"
const TILE_SIZE := 16  # TileMapManager.TILE_SIZE


func on_BombExplode(chain: ModLoaderHookChain, global_pos: Vector2, radius: float, damage: float) -> void:
	chain.execute_next([global_pos, radius, damage])
	if not load(MOD_MAIN_PATH).is_on("fix_blast_edges"):
		return
	var tm := chain.reference_object as TileMapManager
	for tile in _skipped_edge_tiles(tm, global_pos, radius):
		if tm.chunks_created.has(tm.get_chunk_id(tile)):
			tm.damageTileCoords(tile, damage)


func earthquake_pos(chain: ModLoaderHookChain, global_pos: Vector2, damage: float, radius: int) -> void:
	chain.execute_next([global_pos, damage, radius])
	if not load(MOD_MAIN_PATH).is_on("fix_blast_edges"):
		return
	var tm := chain.reference_object as TileMapManager
	for tile in _skipped_edge_tiles(tm, global_pos, radius):
		tm.apply_earthquake_to_tile(tile, damage)


# Tiles inside the blast circle on the last row / last column vanilla's loops stop short of.
static func _skipped_edge_tiles(tm: TileMapManager, global_pos: Vector2, radius: float) -> Array[Vector2i]:
	var top := int(ceil((global_pos.y - radius * TILE_SIZE) / TILE_SIZE))
	var bottom := int(floor((global_pos.y + radius * TILE_SIZE) / TILE_SIZE))
	var left := int(ceil((global_pos.x - radius * TILE_SIZE) / TILE_SIZE))
	var right := int(floor((global_pos.x + radius * TILE_SIZE) / TILE_SIZE))
	var center := global_pos / TILE_SIZE
	var out: Array[Vector2i] = []
	for x in range(left, right + 1):
		var tile := Vector2i(x, bottom)
		if tm.inside_circle(center, tile, radius):
			out.append(tile)
	for y in range(top, bottom):
		var tile := Vector2i(right, y)
		if tm.inside_circle(center, tile, radius):
			out.append(tile)
	return out
