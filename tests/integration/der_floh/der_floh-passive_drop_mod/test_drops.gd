extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Destroyed ores drop a Passive Upgrade card by their chance, with a multiplier by depth layer;
# other blocks only with Non-Ore Blocks above 0.

const MOD_ID := "der_floh-passive_drop_mod"
const LAYER_ROWS := [20, 50, 95, 200, 400, 500, 1400]
const LAYER_MULTIPLIERS := [1.0, 2.0, 3.0, 4.0, 25.0, 36.0, 144.0]
const SETTINGS_ROWS := {
	"Coal": [1.0, "1%"], "Copper": [2.0, "2%"], "Iron": [4.0, "4%"], "Silver": [6.0, "6%"], "Gold": [8.0, "8%"],
	"Amethyst": [10.0, "10%"], "Sapphire": [20.0, "20%"], "Emerald": [30.0, "30%"], "Ruby": [40.0, "40%"],
	"Diamond": [50.0, "50%"], "Pink Diamond": [60.0, "60%"], "Spinel": [70.0, "70%"], "Uranium": [80.0, "80%"],
	"Moonstone": [90.0, "90%"], "Onyx": [100.0, "100%"], "Non-Ore Blocks": [0.0, "0%"],
}
# A card drop lands within this distance of its tile, even for tiles far from the player.
const DROP_SCATTER := 12.0

var _drops: Array = []


func before_each() -> void:
	if not await in_mine():
		return
	_drops = []
	var record := func(position: Vector2, item, _count) -> void:
		_drops.append({"type": item.itemType, "multiplier": item.itemPickupEffect.multiplier if item.itemType == "passive_upgrade" else 0.0, "position": position})
	bus.drop_loot_chest.connect(record)
	on_cleanup(func() -> void: bus.drop_loot_chest.disconnect(record))
	use_setting(MOD_ID, "auto_collect_passives", false)


func test_card_multiplier_follows_the_layer() -> void:
	_use_chance("coal", 100)
	var last_tile := Vector2.ZERO
	for row in LAYER_ROWS:
		last_tile = _destroy(Vector2i(5, row), TileMapChunk.Tiles.COAL_CLAY)
	expect_eq(_drops.map(func(drop) -> float: return drop.multiplier), LAYER_MULTIPLIERS, "card multipliers from layer 0 to 19")
	if not _drops.is_empty():
		expect(_drops.back().position.distance_to(last_tile) <= DROP_SCATTER, "a far tile's card drops at the tile")


func test_chances_decide_the_drops() -> void:
	_use_chance("coal", 0)
	for x in 20:
		_destroy(Vector2i(x, 21), TileMapChunk.Tiles.COAL_CLAY)
	expect_eq(_drops.size(), 0, "cards from coal at 0%")
	_destroy(Vector2i(6, 22), TileMapChunk.Tiles.ONYX_CLAY)
	for block in [TileMapChunk.Tiles.BASIC_CLAY, TileMapChunk.Tiles.HARD_CLAY, TileMapChunk.Tiles.DUNGEON_STONE]:
		_destroy(Vector2i(7, 22), block)
	expect_eq(_drops.size(), 1, "with default chances only onyx (100%) drops")
	_drops.clear()
	_use_chance("non_ore", 100)
	for block in [TileMapChunk.Tiles.BASIC_CLAY, TileMapChunk.Tiles.HARD_CLAY, TileMapChunk.Tiles.DUNGEON_STONE]:
		_destroy(Vector2i(7, 22), block)
	expect_eq(_drops.size(), 3, "rock, chest wall and dungeon stone at Non-Ore Blocks 100%")


func test_disabled_mod_drops_nothing() -> void:
	_use_chance("coal", 100)
	use_setting(MOD_ID, "enabled", false)
	for x in 10:
		_destroy(Vector2i(x, 23), TileMapChunk.Tiles.COAL_CLAY)
	expect_eq(_drops.size(), 0, "cards with the mod disabled")


func test_settings_tab_defaults() -> void:
	var menu = await open_settings()
	var rows := settings_rows(menu, "Passive Drop")
	for label in SETTINGS_ROWS:
		var row = rows.get(label, [])
		expect_eq(row.slice(3, 5) if row.size() == 5 else row, [SETTINGS_ROWS[label][0], SETTINGS_ROWS[label][0]], "%s [value, default]" % label)
	expect_eq(rows.get("Mod Enabled"), true, "Mod Enabled")
	expect_eq(rows.get("Weapon Drops from Chests"), true, "Weapon Drops from Chests")
	expect_eq(rows.get("Chest Generation (new chunks only)"), false, "Chest Generation")
	expect_eq(rows.get("Auto-Collect Dropped Passives"), false, "Auto-Collect")
	var iron = setting_control(menu, "Passive Drop", "Iron")
	if iron:
		iron.slider.value = 77
		expect_eq([mod(MOD_ID).get_chance_for_key("iron"), iron.value_label.text], [77, "77%"], "[chance, label] after moving Iron")
		iron._on_default_pressed()
		expect_eq(mod(MOD_ID).get_chance_for_key("iron"), 4, "Iron after reset")


func _use_chance(key: String, chance: int) -> void:
	var passive_drop = mod(MOD_ID)
	var previous = passive_drop.get_chance_for_key(key)
	passive_drop.set_chance_for_key(key, chance)
	on_cleanup(func() -> void: passive_drop.set_chance_for_key(key, previous))


func _destroy(tile: Vector2i, block) -> Vector2:
	var tm = tilemap()
	var chunk_id: Vector2i = tm.get_chunk_id(tile)
	tm.generate_chunk(chunk_id.x, chunk_id.y)
	var chunk = tm.chunks_created[chunk_id]
	var i: int = chunk.global_pos_to_array(tile)
	chunk.destroy_tile(i, TileMapChunk.TILE_PROPERTIES[block])
	return chunk.to_global(chunk.map_to_local(chunk.array_to_pos(i)))
