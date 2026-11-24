extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Bombers and elementalists mine faster; disabling the mod restores vanilla's 0.5 at once.

const MOD_ID := "ingenitus-employee_balance_mod"
const LEVELS := "res://resources/Employees/EmployeeLevels/%s.tres"
const SPEEDS := {
	"weak_bomber": 0.6, "medium_bomber": 0.7, "strong_bomber": 0.8, "fast_bomber": 0.9, "artillery": 1.0,
	"weak_buffer": 0.6, "medium_buffer": 0.8, "strong_buffer": 1.0,
}
const UNCHANGED := {"weak_aoe": 0.5, "associate_miner": 0.8, "intern": 0.5}
const VANILLA_SPEED := 0.5
const HIRED_LEVEL := "medium_bomber"
const HIRED_COUNT := 3.0


func test_mining_speeds_match_the_table() -> void:
	for level in SPEEDS:
		expect_eq(_speed(level), SPEEDS[level], level)
	for level in UNCHANGED:
		expect_eq(_speed(level), UNCHANGED[level], "%s is unchanged" % level)


func test_disabling_restores_vanilla_speeds() -> void:
	use_setting(MOD_ID, "enabled", false)
	for level in SPEEDS:
		expect_eq(_speed(level), VANILLA_SPEED, "%s with the mod disabled" % level)
	mod(MOD_ID).set_enabled(true)
	for level in SPEEDS:
		expect_eq(_speed(level), SPEEDS[level], "%s after enabling it again" % level)


func test_save_is_untouched() -> void:
	if not await fresh_run():
		return
	gvars.employee_manager.employees[load(LEVELS % HIRED_LEVEL).level_name] = HIRED_COUNT
	var modded := _saved_run()
	use_setting(MOD_ID, "enabled", false)
	expect_eq(_saved_run(), modded, "the run save with the mod disabled")


func _saved_run() -> String:
	gvars.save_game()
	return FileAccess.get_file_as_string(Gconsts.SAVE_GAME_FILE_NAME)


static func _speed(level: String) -> float:
	return load(LEVELS % level).mining_speed
