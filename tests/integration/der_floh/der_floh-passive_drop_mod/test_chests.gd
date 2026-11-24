extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Chest generation is off by default and on as in vanilla when switched on; with Weapon Drops
# off, weapon scrolls in chests become Passive Upgrade cards with the chest's multiplier.

const MOD_ID := "der_floh-passive_drop_mod"
const CHEST_SCENE := "res://scenes/Chest.tscn"
const ROLLS := 200
const CHEST_CHUNK := Vector2i(0, 2)


func before_each() -> void:
	await in_mine()


func test_chest_generation_switch() -> void:
	var tm = tilemap()
	tm.generate_chunk(CHEST_CHUNK.x, CHEST_CHUNK.y)
	var chunk = tm.chunks_created[CHEST_CHUNK]
	var off: Array[Vector2i] = []
	var on: Array[Vector2i] = []
	use_setting(MOD_ID, "chest_generation_enabled", false)
	expect_eq(chunk.generate_chests(off).size(), 0, "chest room tiles generated with Chest Generation off")
	use_setting(MOD_ID, "chest_generation_enabled", true)
	expect(chunk.generate_chests(on).size() > 0, "a chest room is generated with Chest Generation on")


func test_mines_have_no_chests_by_default() -> void:
	if not await fresh_mine():
		return
	await frames(60)
	var chests := 0
	for chunk in tilemap().chunks_created.values():
		chests += chunk.get_children().filter(func(node) -> bool: return node is Chest).size()
	expect_eq(chests, 0, "chests in a new mine with default settings")


func test_weapon_scrolls_become_cards_when_weapon_drops_are_off() -> void:
	use_setting(MOD_ID, "golden_weapons_enabled", false)
	for level in [1, 2, 3, 4]:
		var loot := _roll(level)
		expect(not loot.has("scroll"), "level %d chests hold no scrolls: %s" % [level, loot])
		expect(loot.has("passive_upgrade x%d" % level), "level %d chests hold ×%d cards: %s" % [level, level, loot])
	use_setting(MOD_ID, "golden_weapons_enabled", true)
	expect(_roll(1).has("scroll"), "scrolls come back with Weapon Drops on")


func _roll(level: int) -> Dictionary:
	var chest = load(CHEST_SCENE).instantiate()
	chest.loot_level = level
	var seen := {}
	for i in ROLLS:
		chest.roll_loot()
		var key: String = chest.loot.itemType
		if key == "passive_upgrade":
			key += " x%d" % chest.loot.itemPickupEffect.multiplier
		seen[key] = seen.get(key, 0) + 1
	chest.free()
	return seen
