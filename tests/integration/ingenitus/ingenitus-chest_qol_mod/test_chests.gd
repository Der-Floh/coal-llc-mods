extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Touching a chest opens it (and loots it with One-Click Looting), a chest can be reached from
# its protective ring once one ring tile is mined, and scrolls for weapons no stronger than one
# you own become Passive Upgrade cards.

const MOD_ID := "ingenitus-chest_qol_mod"
const PASSIVE_DROP_ID := "der_floh-passive_drop_mod"
const CHEST_SCENE := "res://scenes/Chest.tscn"
const GOLD_MINIGUN := "res://resources/Items/Equipment/Guns/miniguns/minigun_08_gold.tres"
const RING_CHUNK := Vector2i(0, 1)
const ROLLS := 400
const LABELS := [
	"Open chests when you touch them",
	"Loot straight to inventory on touch (needs One-Click Looting)",
	"Reach chests from their protective tiles once one is mined",
	"Replace power-up scrolls for weapons weaker than yours",
]


func before_each() -> void:
	if await in_mine():
		use_value(gvars.bonus_equipment_manager, "auto_loot_chests", false)


func test_touch_opens_a_chest() -> void:
	expect_eq(await _touch(), {"opened": true, "looted": false}, "touch without One-Click Looting")


func test_touch_loots_with_one_click_looting() -> void:
	gvars.bonus_equipment_manager.auto_loot_chests = true
	expect_eq(await _touch(), {"opened": true, "looted": true}, "touch with One-Click Looting")
	mod(MOD_ID).set_option("auto_grab", false)
	on_cleanup(func() -> void: mod(MOD_ID).set_option("auto_grab", true))
	expect_eq(await _touch(), {"opened": true, "looted": false}, "touch with auto-grab off")


func test_touch_does_nothing_with_auto_open_off_or_the_mod_disabled() -> void:
	gvars.bonus_equipment_manager.auto_loot_chests = true
	mod(MOD_ID).set_option("auto_open", false)
	on_cleanup(func() -> void: mod(MOD_ID).set_option("auto_open", true))
	expect_eq(await _touch(), {"opened": false, "looted": false}, "touch with auto-open off")
	mod(MOD_ID).set_option("auto_open", true)
	use_setting(MOD_ID, "enabled", false)
	expect_eq(await _touch(), {"opened": false, "looted": false}, "touch with the mod disabled")


func test_ring_reach_opens_a_chest_once_the_ring_is_mined() -> void:
	if has_mod(PASSIVE_DROP_ID):
		use_setting(PASSIVE_DROP_ID, "chest_generation_enabled", true)
	var chunk = tilemap().chunks_created[RING_CHUNK]
	var chest = await _generate_chest(chunk)
	if not expect(chest != null, "a chest was generated"):
		return
	var ring: PackedInt32Array = chest.get_meta("ingenitus_ring_tiles")
	expect_eq(ring.size(), 8, "ring tiles")
	chest.set_meta("ingenitus_in_ring", true)
	await frames(3)
	expect(not chest.opened, "an intact ring never gives the chest away")
	chunk.change_tile_idx(ring[0], TileMapChunk.Tiles.EMPTY)
	await frames(3)
	expect(chest.opened, "standing in a breached ring opens the chest")
	expect(not chest.in_range, "it was the ring, not a touch")


func test_weaker_weapon_scrolls_become_cards() -> void:
	expect(_roll(1).has("scroll:minigun"), "minigun scrolls exist without a minigun")
	if not await give(GOLD_MINIGUN):
		return
	var loot := _roll(1)
	expect(not loot.has("scroll:minigun"), "no level-1 minigun scrolls with a gold minigun owned: %s" % [loot])
	expect(loot.has("passive_upgrade x1"), "level-1 cards replace them")


func test_settings_tab() -> void:
	var rows := settings_rows(await open_settings(), "Chests")
	expect_eq(rows.get("Mod Enabled"), true, "Mod Enabled")
	for label in LABELS:
		expect_eq(rows.get(label), true, label)


func _touch() -> Dictionary:
	var chest = load(CHEST_SCENE).instantiate()
	chest.loot_level = 1
	game.current_node.get_node("Chests").add_child(chest)
	chest.global_position = player().global_position + Vector2(0, -600)
	await frames()
	chest._on_area_2d_body_entered(player())
	await frames()
	var result := {"opened": chest.opened, "looted": chest.looted}
	chest.queue_free()
	return result


func _generate_chest(chunk):
	for attempt in 10:
		var before: Array = chunk.get_children().filter(func(node) -> bool: return node is Chest)
		var taken: Array[Vector2i] = []
		chunk.generate_chests(taken)
		await frames(2)
		for node in chunk.get_children():
			if node is Chest and not before.has(node):
				return node
	return null


func _roll(level: int) -> Dictionary:
	var chest = load(CHEST_SCENE).instantiate()
	chest.loot_level = level
	var seen := {}
	for i in ROLLS:
		chest.roll_loot()
		var key: String = chest.loot.itemType
		if key == "scroll":
			key += ":" + chest.loot.itemPickupEffect.item.itemType
		elif key == "passive_upgrade":
			key += " x%d" % chest.loot.itemPickupEffect.multiplier
		seen[key] = seen.get(key, 0) + 1
	chest.free()
	return seen
