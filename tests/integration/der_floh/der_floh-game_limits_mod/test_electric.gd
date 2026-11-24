extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Max Chain Reaction Tiles limits how far an electric pickaxe chain reaches, and Max Visual Arcs
# only limits the drawn arcs, never the damage.

const MOD_ID := "der_floh-game_limits_mod"
const VEIN_ORIGIN := Vector2i(0, 20)
const VEIN_SIZE := 24
const VEIN_TILES := VEIN_SIZE * VEIN_SIZE
const HIT := Vector2i(12, 32)
const UNBREAKABLE_HEALTH := 1e9
const CHAIN_FRAMES := 90


func before_each() -> void:
	if await in_mine():
		player().global_position = Vector2(192, 300)


func test_chain_cap_limits_the_reach() -> void:
	use_setting(MOD_ID, "max_electric_chain", 10)
	var chain := await _shock_vein()
	expect_between(chain.tiles, 1, 10, "tiles reached with a cap of 10")
	use_setting(MOD_ID, "max_electric_chain", 5000)
	chain = await _shock_vein()
	expect_eq(chain.tiles, VEIN_TILES, "a cap of 5000 reaches the whole vein")


func test_visual_cap_never_changes_damage() -> void:
	use_setting(MOD_ID, "max_electric_visuals", 200)
	var drawn := await _shock_vein()
	use_setting(MOD_ID, "max_electric_visuals", 0)
	var hidden := await _shock_vein()
	expect_eq(hidden.arcs, 0, "arcs with Max Visual Arcs at 0")
	expect_eq(hidden.tiles, drawn.tiles, "the same tiles take damage with or without arcs")
	expect(drawn.arcs > 0 and drawn.arcs <= 200, "arcs drawn with a cap of 200: %d" % drawn.arcs)


# Builds a coal vein in BASIC_CLAY with tiles that can't break, swings the electric pickaxe at
# its middle and counts the tiles that took damage and the arcs drawn.
func _shock_vein() -> Dictionary:
	var tm = tilemap()
	for cx in range(-1, 2):
		for cy in range(1, 3):
			tm.generate_chunk(cx, cy)
	for x in range(VEIN_ORIGIN.x - 1, VEIN_ORIGIN.x + VEIN_SIZE + 1):
		for y in range(VEIN_ORIGIN.y - 1, VEIN_ORIGIN.y + VEIN_SIZE + 1):
			var inside := x >= VEIN_ORIGIN.x and x < VEIN_ORIGIN.x + VEIN_SIZE and y >= VEIN_ORIGIN.y and y < VEIN_ORIGIN.y + VEIN_SIZE
			_put(Vector2i(x, y), TileMapChunk.Tiles.COAL_CLAY if inside else TileMapChunk.Tiles.BASIC_CLAY)
	var p = player()
	p.electric_shock_on = true
	p.aoe_strikes = false
	p.pickaxe_strength = 100.0
	p.strength_buff = 1.0
	p.able_to_mine = true
	p.mine_where_mouse_is = true
	p.ReadyToMine = true
	p.live_ray_cast = p.ray_cast_top
	p.pointer_global_pos = Vector2(HIT.x * 16 + 8, HIT.y * 16 + 8)
	p.mine_action()
	p.electric_shock_on = false
	var shocks: Array = p.get_parent().get_children().filter(func(node) -> bool: return node is ElectricShock)
	var arcs := [0]
	if not shocks.is_empty():
		shocks.back().child_entered_tree.connect(func(_node) -> void: arcs[0] += 1)
	await physics_frames(CHAIN_FRAMES)
	var damaged := 0
	for x in range(VEIN_ORIGIN.x, VEIN_ORIGIN.x + VEIN_SIZE):
		for y in range(VEIN_ORIGIN.y, VEIN_ORIGIN.y + VEIN_SIZE):
			if _lost(Vector2i(x, y)) > 0.0:
				damaged += 1
	return {"tiles": damaged, "arcs": arcs[0]}


func _put(tile: Vector2i, kind) -> void:
	var tm = tilemap()
	tm.change_tile(tile, kind)
	var chunk = tm.chunks_created[tm.get_chunk_id(tile)]
	chunk.tiles_health[chunk.global_pos_to_array(tile)] = UNBREAKABLE_HEALTH


func _lost(tile: Vector2i) -> float:
	var chunk = tilemap().chunks_created[tilemap().get_chunk_id(tile)]
	return UNBREAKABLE_HEALTH - chunk.tiles_health[chunk.global_pos_to_array(tile)]
