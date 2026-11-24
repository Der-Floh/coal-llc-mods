extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Level-up cards label the new passives with their name and step times the card multiplier,
# picking one applies it, and every profession's pool holds all ten (assassins also Wet Damage).

const MOD_ID := "ingenitus-extra_passives_mod"
const CARD_MULTIPLIER := 3.0


func before_each() -> void:
	if await in_mine():
		mod(MOD_ID).reset_passives()
		on_cleanup(func() -> void: mod(MOD_ID).reset_passives())


func test_card_labels_and_pick() -> void:
	bus.choose_passive.emit(CARD_MULTIPLIER)
	await frames()
	var card = _open_card()
	if not expect(card != null, "a card opened"):
		return
	card.choose_between = ["gun_fire_rate", "multi_projectile", "player_jump_velocity"]
	card.set_up_buttons()
	var labels := [card.button.text, card.button_2.text, card.button_3.text]
	expect(labels[0].begins_with("Increase Gun Fire Rate +15"), "label: %s" % labels[0])
	expect(labels[1].begins_with("Increase Extra Projectiles +30"), "label: %s" % labels[1])
	expect(labels[2].begins_with("Increase Player Jump Velocity +30"), "vanilla label: %s" % labels[2])
	card._on_button_2_pressed()
	await frames()
	expect_near(mod(MOD_ID).level("multi_projectile"), 0.3, 1e-6, "Extra Projectiles after a ×3 pick")
	expect_eq(gvars.passives.player_jump_velocity, 0.0, "the other options weren't applied")
	expect(not tree.paused, "the game runs again after the pick")


func test_every_profession_can_get_all_ten() -> void:
	var extra_passives = mod(MOD_ID)
	var professions = gvars.profession_manager.all_professions
	var missing := {}
	for id in professions:
		var profession = professions[id]["profession"]
		var pool: Array = profession._profession_effect({"unlocked_passives": []})["unlocked_passives"]
		var lacking: Array = extra_passives.PASSIVES.keys().filter(func(key) -> bool: return not pool.has(key))
		if not lacking.is_empty():
			missing[profession.profession_name] = lacking
	expect_eq(missing, {}, "professions missing passives")
	var assassin_pool: Array = load("res://resources/professions/assassin.tres")._profession_effect({"unlocked_passives": []})["unlocked_passives"]
	expect(assassin_pool.has("wet_damage"), "assassins can be offered Wet Damage")


func _open_card():
	var cards: Array = gui().get_children().filter(func(node) -> bool: return "choose_between" in node and node.live)
	return cards.back() if not cards.is_empty() else null
