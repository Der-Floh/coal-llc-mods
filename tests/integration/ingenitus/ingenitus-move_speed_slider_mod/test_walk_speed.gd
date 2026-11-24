extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Walking can be raised up to the current sprint speed (sprint passive, sprint slider and the
# speed quest reward count), from a Tab row that follows the sprint slider. The value is a
# config setting, not part of the save.

const MOD_ID := "ingenitus-move_speed_slider_mod"
const BASE_WALK := 100.0
const BASE_SPRINT := 150.0
const SLIDER_NAME := "IngenitusWalkSpeedSlider"


func before_each() -> void:
	if not await in_mine():
		return
	var passives = gvars.passives
	use_value(passives, "player_sprint_speed", 0.0)
	use_value(passives, "adjusted_player_sprint_speed", 0.0)
	use_value(gvars.bonus_equipment_manager, "passive_player_speed_increase", false)
	use_value(gvars.settings, "auto_sprint", false)
	on_cleanup(func() -> void: mod(MOD_ID).set_walk_bonus(0.0))
	Input.action_release("sprint")


func test_limit_follows_sprint() -> void:
	var move_speed = mod(MOD_ID)
	expect_near(move_speed.max_walk_bonus(), 0.5, 1e-6, "limit without upgrades")
	gvars.passives.player_sprint_speed = 0.2
	gvars.passives.adjusted_player_sprint_speed = 0.2
	expect_near(move_speed.max_walk_bonus(), 0.8, 1e-6, "limit with a +20% sprint passive")
	gvars.passives.adjusted_player_sprint_speed = 0.1
	expect_near(move_speed.max_walk_bonus(), 0.65, 1e-6, "limit with the sprint slider lowered to +10%")
	gvars.passives.player_sprint_speed = 0.0
	gvars.passives.adjusted_player_sprint_speed = 0.0
	gvars.bonus_equipment_manager.passive_player_speed_increase = true
	expect_near(move_speed.max_walk_bonus(), 2.0, 1e-6, "limit with the speed quest reward")


func test_walking_speed_is_capped_at_sprint() -> void:
	var move_speed = mod(MOD_ID)
	var cases := [[0.3, 0.0, 0.0, 130.0], [1.0, 0.0, 0.0, 150.0], [1.0, 0.2, 0.2, 180.0], [1.0, 0.2, 0.1, 165.0]]
	for case in cases:
		move_speed.set_walk_bonus(case[0])
		gvars.passives.player_sprint_speed = case[1]
		gvars.passives.adjusted_player_sprint_speed = case[2]
		await physics_frames(2)
		expect_eq(player().speed, case[3], "walk +%d%%, sprint passive +%d%%, sprint slider +%d%%" % [case[0] * 100, case[1] * 100, case[2] * 100])


func test_auto_sprint_walks_at_the_slider_speed() -> void:
	mod(MOD_ID).set_walk_bonus(0.3)
	gvars.settings.auto_sprint = true
	Input.action_press("sprint")
	await physics_frames(2)
	expect_eq(player().speed, BASE_WALK * 1.3, "holding Sprint with Auto Sprint walks at the slider speed")
	Input.action_release("sprint")
	await physics_frames(2)
	expect_eq(player().speed, BASE_SPRINT, "letting go sprints")


func test_tab_row_follows_the_sprint_slider() -> void:
	gvars.passives.player_sprint_speed = 0.2
	gvars.passives.adjusted_player_sprint_speed = 0.2
	mod(MOD_ID).set_walk_bonus(0.8)
	var panel = gui().find_child("PassiveBonuses", true, false)
	panel.refresh()
	await frames()
	var row = _walk_row(panel)
	var sprint = _sprint_row(panel)
	if not expect(row != null and sprint != null, "the walk and sprint rows exist"):
		return
	expect_eq(_row_state(row), ["Walk Speed (up to sprint) +80%", 0.8, 0.8], "[label, max, value] at +20% sprint")
	sprint.h_slider.value = 0.1
	expect_eq(_row_state(row), ["Walk Speed (up to sprint) +65%", 0.65, 0.65], "after lowering the sprint slider to +10%")
	expect_near(mod(MOD_ID).walk_bonus, 0.8, 1e-6, "the chosen walk bonus is kept")
	sprint.h_slider.value = 0.2
	expect_eq(_row_state(row), ["Walk Speed (up to sprint) +80%", 0.8, 0.8], "after raising the sprint slider again")


func test_value_lives_in_the_config() -> void:
	mod(MOD_ID).set_walk_bonus(0.25)
	expect(FileAccess.get_file_as_string(mod(MOD_ID).get_config().save_path).contains("0.25"), "the config file holds the walk bonus")
	gvars.save_game()
	expect(not FileAccess.get_file_as_string("user://v04_savegame.save").contains("walk"), "the run save doesn't")


func test_disabled_mod_removes_the_row_and_bonus() -> void:
	mod(MOD_ID).set_walk_bonus(0.3)
	use_setting(MOD_ID, "enabled", false)
	var panel = gui().find_child("PassiveBonuses", true, false)
	panel.refresh()
	expect(_walk_row(panel) == null, "no walk row with the mod disabled")
	await physics_frames(2)
	expect_eq(player().speed, BASE_WALK, "walking speed with the mod disabled")


static func _walk_row(panel):
	var sliders: Array = panel.find_children(SLIDER_NAME, "", true, false).filter(func(slider) -> bool: return not slider.get_parent().is_queued_for_deletion())
	return sliders.back().get_parent() if not sliders.is_empty() else null


static func _sprint_row(panel):
	var rows: Array = panel.get_children().filter(func(row) -> bool: return row is PassiveBonusAdjustable and row.property_name == "player_sprint_speed" and not row.is_queued_for_deletion())
	return rows.back() if not rows.is_empty() else null


static func _row_state(row) -> Array:
	return [row.get_child(0).text, snappedf(row.get_child(1).max_value, 0.001), snappedf(row.get_child(1).value, 0.001)]
