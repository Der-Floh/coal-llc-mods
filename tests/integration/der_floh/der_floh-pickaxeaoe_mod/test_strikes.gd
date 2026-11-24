extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Electric pickaxe chains and AOE blasts deal the swing's full damage to every tile they reach,
# the hit tile only once, and chains stay within one tile type.

const BUG_FIXES_ID := "ingenitus-bug_fixes_mod"
const UNBREAKABLE_HEALTH := 1e9
const VEIN_ORIGIN := Vector2i(0, 20)
const VEIN_SIZE := 24
const VEIN_HIT := Vector2i(12, 32)
const BLAST_HIT := Vector2i(11, 21)
const CHAIN_FRAMES := 90
const SPARK_SCENE_PARENT_CHANGE := 0


func before_each() -> void:
	if await in_mine():
		player().global_position = Vector2(192, 300)


func test_electric_chain_deals_full_damage_within_the_vein() -> void:
	var tm = tilemap()
	for cx in range(-1, 2):
		for cy in range(1, 3):
			tm.generate_chunk(cx, cy)
	for x in range(VEIN_ORIGIN.x - 1, VEIN_ORIGIN.x + VEIN_SIZE + 1):
		for y in range(VEIN_ORIGIN.y - 1, VEIN_ORIGIN.y + VEIN_SIZE + 1):
			var inside := x >= VEIN_ORIGIN.x and x < VEIN_ORIGIN.x + VEIN_SIZE and y >= VEIN_ORIGIN.y and y < VEIN_ORIGIN.y + VEIN_SIZE
			_put(Vector2i(x, y), TileMapChunk.Tiles.COAL_CLAY if inside else TileMapChunk.Tiles.BASIC_CLAY)
	var swing_damage := _swing(VEIN_HIT, true, false)
	await physics_frames(CHAIN_FRAMES)
	var damage_values := {}
	var outside_vein := 0
	for x in range(VEIN_ORIGIN.x - 1, VEIN_ORIGIN.x + VEIN_SIZE + 1):
		for y in range(VEIN_ORIGIN.y - 1, VEIN_ORIGIN.y + VEIN_SIZE + 1):
			var lost := _lost(Vector2i(x, y))
			if lost <= 0.0:
				continue
			var inside := x >= VEIN_ORIGIN.x and x < VEIN_ORIGIN.x + VEIN_SIZE and y >= VEIN_ORIGIN.y and y < VEIN_ORIGIN.y + VEIN_SIZE
			if not inside:
				outside_vein += 1
			damage_values[lost] = damage_values.get(lost, 0) + 1
	expect_eq(damage_values.keys(), [swing_damage], "damage per chained tile")
	expect_between(damage_values.get(swing_damage, 0), 400, 500, "tiles the chain reached")
	expect_eq(_lost(VEIN_HIT), swing_damage, "the hit tile takes the damage once")
	expect_eq(outside_vein, 0, "tiles damaged outside the vein")


func test_aoe_blast_deals_full_damage() -> void:
	for x in range(BLAST_HIT.x - 3, BLAST_HIT.x + 4):
		for y in range(BLAST_HIT.y - 3, BLAST_HIT.y + 4):
			_put(Vector2i(x, y), TileMapChunk.Tiles.BASIC_CLAY)
	var parent_children: int = player().get_parent().get_child_count()
	var swing_damage := _swing(BLAST_HIT, false, true)
	var hit := {}
	for x in range(BLAST_HIT.x - 3, BLAST_HIT.x + 4):
		for y in range(BLAST_HIT.y - 3, BLAST_HIT.y + 4):
			var lost := _lost(Vector2i(x, y))
			if lost > 0.0:
				hit[Vector2i(x, y) - BLAST_HIT] = lost
	var full_edges: bool = has_mod(BUG_FIXES_ID) and mod(BUG_FIXES_ID).is_on("fix_blast_edges")
	expect_eq(hit.size(), 12 if full_edges else 8, "tiles the blast reached (Bug Fixes' blast-edge fix: %s)" % full_edges)
	expect(hit.has(Vector2i.ZERO), "the hit tile is part of the blast")
	expect(hit.values().all(func(lost: float) -> bool: return is_equal_approx(lost, swing_damage)), "every blast tile takes %s: %s" % [swing_damage, hit])
	expect_eq(player().get_parent().get_child_count() - parent_children, SPARK_SCENE_PARENT_CHANGE, "sparks come from the pool, not new nodes")
	player().aoe_strikes = false


func _swing(tile: Vector2i, electric: bool, aoe: bool) -> float:
	var p = player()
	p.electric_shock_on = electric
	p.aoe_strikes = aoe
	p.pickaxe_strength = 100.0
	p.strength_buff = 1.0
	p.able_to_mine = true
	p.mine_where_mouse_is = true
	p.ReadyToMine = true
	p.live_ray_cast = p.ray_cast_top
	p.pointer_global_pos = Vector2(tile.x * 16 + 8, tile.y * 16 + 8)
	p.mine_action()
	p.electric_shock_on = false
	return 100.0 * (1 + gvars.passives.player_pickaxe_mining_damage) * maxf(25.0, 1 + gvars.passives.player_pickaxe_mining_speed) / 25.0


func _put(tile: Vector2i, kind) -> void:
	var tm = tilemap()
	tm.change_tile(tile, kind)
	var chunk = tm.chunks_created[tm.get_chunk_id(tile)]
	chunk.tiles_health[chunk.global_pos_to_array(tile)] = UNBREAKABLE_HEALTH


func _lost(tile: Vector2i) -> float:
	var chunk = tilemap().chunks_created[tilemap().get_chunk_id(tile)]
	return UNBREAKABLE_HEALTH - chunk.tiles_health[chunk.global_pos_to_array(tile)]
