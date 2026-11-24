extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Auto-Collect turns dropped cards straight into level-up cards, one per frame, instead of items
# in the world; AutoPassiveChooser then picks them.

const MOD_ID := "der_floh-passive_drop_mod"
const CHOOSER_ID := "NanobotZ-AutoPassiveChooser"
const DROPS := 3


func before_each() -> void:
	if await in_mine():
		use_setting(MOD_ID, "auto_collect_passives", true)
		var passive_drop = mod(MOD_ID)
		var previous = passive_drop.get_chance_for_key("coal")
		passive_drop.set_chance_for_key("coal", 100)
		on_cleanup(func() -> void: passive_drop.set_chance_for_key("coal", previous))


func test_cards_open_one_per_frame_without_world_items() -> void:
	if has_mod(CHOOSER_ID):
		skip("AutoPassiveChooser picks the cards before they can be counted")
		return
	var world_items := [0]
	var count := func(_position, _item, _count) -> void: world_items[0] += 1
	bus.drop_loot_chest.connect(count)
	on_cleanup(func() -> void: bus.drop_loot_chest.disconnect(count))
	_destroy_coal()
	var queue := [mod(MOD_ID)._passive_queue.size()]
	for i in DROPS:
		await frames()
		queue.append(mod(MOD_ID)._passive_queue.size())
	expect_eq(world_items[0], 0, "cards dropped as world items")
	expect_eq(queue, [3, 2, 1, 0], "queued cards per frame")


func test_auto_passive_chooser_picks_collected_cards() -> void:
	if not require_mods([CHOOSER_ID]):
		return
	var config = mod(CHOOSER_ID).get_or_create_config()
	use_value(config, "data", config.data.duplicate(true))
	config.data["reroll_if_no_matches"] = true
	var cash_before: float = gvars.CashCount
	var passives_before := _passive_total()
	_destroy_coal()
	await frames(30)
	var open_cards: Array = gui().get_children().filter(func(node) -> bool: return "choose_between" in node and node.live)
	expect_eq(open_cards.size(), 0, "cards left open")
	expect(_passive_total() > passives_before or gvars.CashCount > cash_before, "the cards were picked or taken as cash")
	expect(not tree.paused, "the game keeps running")


func _destroy_coal() -> void:
	var tm = tilemap()
	var chunk = tm.chunks_created[Vector2i(0, 1)]
	for x in DROPS:
		chunk.destroy_tile(chunk.global_pos_to_array(Vector2i(x, 20)), TileMapChunk.TILE_PROPERTIES[TileMapChunk.Tiles.COAL_CLAY])


func _passive_total() -> float:
	var total := 0.0
	for key in ChoosePassive.ALL_PASSIVES:
		total += float(gvars.passives.get(key))
	return total
