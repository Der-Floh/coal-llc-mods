extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# A destroyed tile with poison, fire or wetness passes it to every breakable tile in the
# square around it, with its remaining ticks or a fresh count.

const MOD_ID := "der_floh-effect_spread_mod"
const TICK_ID := "der_floh-tick_upgrade_mod"
# Each spread in a test gets its own square of clay: the largest tested radius plus the ring outside it.
const ORIGINS := [Vector2i(-24, 30), Vector2i(-8, 30), Vector2i(8, 30)]
const CLAY_MARGIN := 6
const DESTROY_DAMAGE := 1e15
const TICKS := 10

var _spreads := 0


func before_each() -> void:
	_spreads = 0
	await in_mine()


func test_poison_fire_and_wetness_spread_at_radius_3() -> void:
	expect_eq(await _spread("poison", 3), {"[10, 1.0]": 48}, "poison")
	expect_eq(await _spread("burn", 3), {"[10, 1.0]": 48}, "fire")
	expect_eq(await _spread("wet", 3), {"wet": 48}, "wetness")


func test_spread_radius_setting() -> void:
	use_setting(MOD_ID, "spread_radius", 1)
	expect_eq(await _spread("poison", 1), {"[10, 1.0]": 8}, "radius 1")
	use_setting(MOD_ID, "spread_radius", 5)
	expect_eq(await _spread("poison", 5), {"[10, 1.0]": 120}, "radius 5")


func test_fresh_ticks_when_not_inheriting() -> void:
	use_setting(MOD_ID, "inherit_ticks", false)
	use_setting(MOD_ID, "fresh_ticks", 7)
	expect_eq(await _spread("poison", 3), {"[7, 1.0]": 48}, "fresh tick count")


func test_disabled_mod_spreads_nothing() -> void:
	use_setting(MOD_ID, "enabled", false)
	expect_eq(await _spread("poison", 3), {}, "spread with the mod disabled")


func test_tick_upgrade_scales_spread_ticks() -> void:
	if not require_mods([TICK_ID]):
		return
	mod(TICK_ID).set_passive("poison_tick_speed", 1.0)
	on_cleanup(func() -> void: mod(TICK_ID).reset_passives())
	expect_eq(await _spread("poison", 3), {"[40, 1.0]": 48}, "Preserve duration scales the 20 inherited ticks again")


func test_settings_tab_defaults() -> void:
	var menu = await open_settings()
	var rows := settings_rows(menu, "Effect Spread")
	expect_eq(rows.get("Mod Enabled"), true, "Mod Enabled")
	expect_eq(_row(rows, "Spread Radius").slice(0, 2) + _row(rows, "Spread Radius").slice(3), [1.0, 20.0, 3.0, 3.0], "Spread Radius [min, max, value, default]")
	expect_eq(_row(rows, "Inherit remaining ticks"), true, "Inherit remaining ticks")
	expect_eq(_row(rows, "Fresh tick count").slice(0, 2) + _row(rows, "Fresh tick count").slice(3), [1.0, 50.0, 10.0, 10.0], "Fresh tick count [min, max, value, default]")


func _spread(kind: String, radius: int) -> Dictionary:
	var tm = tilemap()
	var origin: Vector2i = ORIGINS[_spreads]
	_spreads += 1
	_fill_with_clay(origin)
	match kind:
		"poison":
			tm.poison_tile_coords(origin, 1.0, TICKS)
		"burn":
			tm.burn_tile_coords(origin, 1.0, TICKS)
		"wet":
			tm.wet_tile_coords(origin)
	tm.damageTileCoords(origin, DESTROY_DAMAGE)
	await physics_frames(2)
	expect_eq(tm.get_tile_enum(origin), 0, "%s origin destroyed" % kind)
	var spread := {}
	var outside := 0
	for dy in range(-radius - 1, radius + 2):
		for dx in range(-radius - 1, radius + 2):
			var value = _effect(origin + Vector2i(dx, dy), kind)
			if value == null:
				continue
			if maxi(absi(dx), absi(dy)) > radius:
				outside += 1
			else:
				spread[str(value)] = spread.get(str(value), 0) + 1
	expect_eq(outside, 0, "%s tiles outside radius %d" % [kind, radius])
	return spread


func _effect(tile: Vector2i, kind: String):
	var chunk = tilemap().chunks_created[tilemap().get_chunk_id(tile)]
	var i: int = chunk.global_pos_to_array(tile)
	if kind == "poison" and chunk.poison_tiles.has(i):
		return [chunk.poison_tiles_set[chunk.poison_tiles[i]["poison_idx"]][i], chunk.poison_tiles[i]["damage"]]
	if kind == "burn" and chunk.burn_tiles.has(i):
		return [chunk.burn_tiles_set[chunk.burn_tiles[i]["burn_idx"]][i], chunk.burn_tiles[i]["damage"]]
	if kind == "wet" and chunk.wet_tiles.has(i):
		return "wet"
	return null


func _fill_with_clay(origin: Vector2i) -> void:
	var tm = tilemap()
	tm.generate_chunks(tm.map_to_local(origin))
	for dy in range(-CLAY_MARGIN, CLAY_MARGIN + 1):
		for dx in range(-CLAY_MARGIN, CLAY_MARGIN + 1):
			tm.change_tile(origin + Vector2i(dx, dy), TileMapChunk.Tiles.BASIC_CLAY)


static func _row(rows: Dictionary, label_start: String):
	for label in rows:
		if String(label).begins_with(label_start):
			return rows[label]
	return []
