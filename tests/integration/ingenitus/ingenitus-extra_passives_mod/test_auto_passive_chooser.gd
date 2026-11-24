extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# AutoPassiveChooser lists all ten passives for every profession, keeps priorities for passives
# that can't be offered right now, and its Up to limit stops picking one.

const MOD_ID := "ingenitus-extra_passives_mod"
const CHOOSER_ID := "NanobotZ-AutoPassiveChooser"
const UP_TO_PERCENT := 10


func before_each() -> void:
	if not require_mods([CHOOSER_ID]) or not await in_mine():
		return
	mod(MOD_ID).reset_passives()
	on_cleanup(func() -> void: mod(MOD_ID).reset_passives())
	var config = mod(CHOOSER_ID).get_or_create_config()
	use_value(config, "data", config.data.duplicate(true))


func test_priority_list_shows_all_ten_for_every_profession() -> void:
	var menu = await open_settings()
	var order = menu.tab_container.get_node("PassiveOrder")
	var keys: Array = mod(MOD_ID).PASSIVES.keys()
	var missing := {}
	for i in order.profession_option.item_count:
		order._on_profession_changed(i)
		var listed: Array = order.grid.get_children().map(func(node) -> String: return String(node.name).split("$")[1] if String(node.name).contains("$") else String(node.name))
		var lacking := keys.filter(func(key) -> bool: return not listed.has(key))
		if not lacking.is_empty():
			missing[order.profession_option.get_item_text(i)] = lacking
	expect_eq(missing, {}, "professions whose list misses passives")


func test_confirming_keeps_priorities_of_passives_not_on_offer() -> void:
	var config = mod(CHOOSER_ID).get_or_create_config()
	config.data["passive_order"] = [{"enabled": true, "effect": "bomb_radius", "upTo": 0}]
	var menu = await open_settings()
	var order = menu.tab_container.get_node("PassiveOrder")
	order._on_profession_changed(0)
	order._on_confirm_pressed()
	var effects: Array = config.data["passive_order"].map(func(entry) -> String: return entry["effect"])
	expect(effects.has("bomb_radius"), "bomb_radius priority after confirming without a bomb: %s" % [effects])


func test_up_to_limit_stops_auto_picks() -> void:
	var config = mod(CHOOSER_ID).get_or_create_config()
	config.data["passive_order"] = [{"enabled": true, "effect": "gun_fire_rate", "upTo": UP_TO_PERCENT}]
	config.data["reroll_if_no_matches"] = false
	var rounds := []
	for round in 3:
		bus.choose_passive.emit(1.0)
		await frames()
		var card = _open_card()
		if card:
			card.choose_between = ["player_climb_speed", "gun_fire_rate", "multi_projectile"]
		await frames(4)
		rounds.append([_open_card() == null, snappedf(mod(MOD_ID).level("gun_fire_rate"), 0.01)])
		var still_open = _open_card()
		if still_open:
			still_open.live = false
			still_open.queue_free()
			tree.paused = false
	expect_eq(rounds, [[true, 0.05], [true, 0.1], [false, 0.1]], "[card closed, Gun Fire Rate] per round")


func _open_card():
	var cards: Array = gui().get_children().filter(func(node) -> bool: return "choose_between" in node and node.live)
	return cards.back() if not cards.is_empty() else null
