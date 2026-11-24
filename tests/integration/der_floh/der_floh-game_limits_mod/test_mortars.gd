extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Max Active Mortars caps the shells in the air; a shot held back at the cap adds its damage to
# the next shell, and lowering the cap keeps the pool the level already built.

const MOD_ID := "der_floh-game_limits_mod"
const TARGET := Vector2(100, -3000)


func before_each() -> void:
	await fresh_mine()


func test_cap_holds_back_shots_and_keeps_their_damage() -> void:
	var mortars = game.current_node.get_node("MortarManager")
	use_setting(MOD_ID, "max_mortars", 50)
	for i in 80:
		mortars.shoot_mortar(TARGET, 1.0)
	expect_eq([mortars.max_mortars, mortars.live_mortars.count(1), mortars.buffer_damage], [50, 50, 30.0], "[pool, live shells, held damage] after 80 shots at a cap of 50")
	mortars.live_mortars[0] = 0
	mortars.idx = 0
	mortars.shoot_mortar(TARGET, 1.0)
	expect_eq([mortars.mortar_damages[0], mortars.buffer_damage], [31.0, 0.0], "the next shell carries the held damage")


func test_pool_grows_past_vanilla_and_survives_a_lower_cap() -> void:
	var mortars = game.current_node.get_node("MortarManager")
	use_setting(MOD_ID, "max_mortars", 1500)
	for i in 1300:
		mortars.shoot_mortar(TARGET, 1.0)
	expect_eq([mortars.max_mortars, mortars.buffer_damage], [1300, 0.0], "[pool, held damage] after 1300 shots with a cap of 1500")
	mortars.live_mortars.fill(0)
	mod(MOD_ID).set_max_mortars(50)
	for i in 200:
		mortars.shoot_mortar(TARGET, 1.0)
	expect_eq([mortars.max_mortars, mortars.live_mortars.count(1)], [1300, 200], "[pool, live shells] after lowering the cap to 50")
