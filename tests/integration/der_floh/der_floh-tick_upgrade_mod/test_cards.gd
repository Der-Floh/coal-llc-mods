extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Poison Tick Speed is offered with a poison gun or staff, Fire Tick Speed with a flamethrower,
# each +10% per step times the card's multiplier.

const MOD_ID := "der_floh-tick_upgrade_mod"
const POISON_STAFF := "res://resources/Items/Equipment/staffs/poison_staff_1.tres"
const FLAMETHROWER := "res://resources/Items/Equipment/alternative_guns/flamethrowers/flamethrower_01_shoddy.tres"
const PISTOL := "res://resources/Items/Equipment/Guns/pistols/pistol_01_shoddy.tres"
const CARDS := 120
const CARD_MULTIPLIER := 2.0


func before_each() -> void:
	if await fresh_mine():
		mod(MOD_ID).reset_passives()


func test_no_tick_passives_without_a_matching_weapon() -> void:
	var seen := await _offers()
	expect(not seen.has("poison_tick_speed") and not seen.has("fire_tick_speed"), "offered: %s" % [seen.keys()])


func test_poison_weapon_offers_only_poison_tick_speed() -> void:
	if not await give(POISON_STAFF):
		return
	var seen := await _offers()
	expect(seen.has("poison_tick_speed"), "poison_tick_speed offered with a poison staff")
	expect(not seen.has("fire_tick_speed"), "fire_tick_speed not offered without a flamethrower")


func test_labels_show_ten_percent_steps() -> void:
	for item in [POISON_STAFF, FLAMETHROWER, PISTOL]:
		if not await give(item):
			return
	var seen := await _offers()
	for key in ["poison_tick_speed", "fire_tick_speed"]:
		if expect(seen.has(key), "%s offered" % key):
			expect(String(seen[key]).ends_with("+20.0%"), "%s label at ×2: %s" % [key, seen[key]])
	for key in seen:
		expect(not String(seen[key]).contains("Multi Projectile"), "Extra Passives labels keep their names: %s" % seen[key])


func test_picking_a_card_raises_the_speed() -> void:
	if not await give(POISON_STAFF):
		return
	bus.choose_passive.emit(CARD_MULTIPLIER)
	await frames()
	var card = _open_card()
	if not expect(card != null, "a card opened"):
		return
	card.choose_between = ["poison_tick_speed", "player_jump_velocity", "player_sprint_speed"]
	card._on_button_pressed()
	await frames()
	expect_near(mod(MOD_ID).get_poison_tick_speed(), 1.2, 1e-6, "multiplier after a ×2 pick")
	expect(not tree.paused, "the game runs again after the pick")


func _offers() -> Dictionary:
	var seen := {}
	for i in CARDS:
		bus.choose_passive.emit(CARD_MULTIPLIER)
		var card = _open_card()
		if card == null:
			continue
		var buttons := [card.button, card.button_2, card.button_3]
		for j in buttons.size():
			seen[card.choose_between[j]] = buttons[j].text
		card.live = false
		card.queue_free()
	tree.paused = false
	await frames()
	return seen


func _open_card():
	var cards: Array = gui().get_children().filter(func(node) -> bool: return "choose_between" in node and node.live)
	return cards.back() if not cards.is_empty() else null
