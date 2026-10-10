extends Object

# fix_aoe_gap for flying miners (same function as multi_miner.hooks.gd).
# AOE employees' strikes damage "surrounding tiles" (their tooltip), but
# get_radius keeps a tile only when x != 0 AND y != 0, which drops the whole row and
# column through the target: at aoe_range 1 only the four diagonal tiles are hit,
# never the ones directly above, below, left or right. The square is returned
# without only its centre (the target, damaged separately by vanilla).

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-bug_fixes_mod/mod_main.gd"


func get_radius(chain: ModLoaderHookChain, tile: Vector2i, radius: int) -> Array[Vector2i]:
	if not load(MOD_MAIN_PATH).is_on("fix_aoe_gap"):
		return chain.execute_next([tile, radius])
	var tiles: Array[Vector2i] = []
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			if x != 0 or y != 0:
				tiles.append(Vector2i(tile.x + x, tile.y + y))
	return tiles
