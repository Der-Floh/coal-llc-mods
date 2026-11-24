extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# AutoPassiveChooser can prioritise both tick passives, and its Up to limit works for them.

const MOD_ID := "der_floh-tick_upgrade_mod"
const CHOOSER_ID := "NanobotZ-AutoPassiveChooser"
const POISON_STAFF := "res://resources/Items/Equipment/staffs/poison_staff_1.tres"
const UP_TO_PERCENT := 20


func test_up_to_limit_stops_auto_picks() -> void:
	if not require_mods([CHOOSER_ID]) or not await fresh_mine() or not await give(POISON_STAFF):
		return
	mod(MOD_ID).reset_passives()
	var config = mod(CHOOSER_ID).get_or_create_config()
	use_value(config, "data", config.data.duplicate(true))
	config.data["passive_order"] = [{"enabled": true, "effect": "poison_tick_speed", "upTo": UP_TO_PERCENT}]
	config.data["reroll_if_no_matches"] = false
	var picked := []
	for round in 3:
		bus.choose_passive.emit(1.0)
		await frames()
		var card = _open_card()
		if card:
			card.choose_between = ["player_climb_speed", "poison_tick_speed", "orb_damage"]
		await frames(4)
		var left_open = _open_card()
		picked.append([left_open == null, snappedf(gvars.passives.get("poison_tick_speed"), 0.01)])
		if left_open:
			left_open.live = false
			left_open.queue_free()
			tree.paused = false
	expect_eq(picked, [[true, 0.1], [true, 0.2], [false, 0.2]], "[card closed, poison bonus] per round")
	mod(MOD_ID).reset_passives()


func _open_card():
	var cards: Array = gui().get_children().filter(func(node) -> bool: return "choose_between" in node and node.live)
	return cards.back() if not cards.is_empty() else null
