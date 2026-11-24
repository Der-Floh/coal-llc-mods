extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# The Game Limits tab: its ranges and defaults, out-of-range config values corrected when the
# menu opens, and the employee slider shared with the game's own.

const MOD_ID := "der_floh-game_limits_mod"
const TAB := "Game Limits"
const EXPECTED_SLIDERS := {
	"Max Active Mortars": [50.0, 10000.0, 50.0, 1000.0, 1000.0],
	"Max Employee Entities Drawn": [50.0, 10000.0, 25.0, 500.0, 500.0],
	"Chunk Load Radius": [1.0, 100.0, 1.0, 3.0, 3.0],
	"Chunks Generated Per Frame": [1.0, 10.0, 1.0, 1.0, 1.0],
	"Max Chain Reaction Tiles": [10.0, 5000.0, 10.0, 500.0, 500.0],
	"Max Visual Arcs": [0.0, 1000.0, 10.0, 200.0, 200.0],
}
const OUT_OF_RANGE := {"max_mortars": 20, "chunks_per_frame": 50, "max_electric_visuals": 5000, "max_electric_chain": 5, "chunk_load_radius": 500}
const CORRECTED := {"max_mortars": 50, "chunks_per_frame": 10, "max_electric_visuals": 1000, "max_electric_chain": 10, "chunk_load_radius": 100}


func before_each() -> void:
	await in_management()


func test_tab_ranges_and_defaults() -> void:
	var rows := settings_rows(await open_settings(), TAB)
	expect_eq(rows.get("Mod Enabled"), true, "Mod Enabled")
	for label_start in EXPECTED_SLIDERS:
		var label: String = _label(rows, label_start)
		expect_eq(rows.get(label), EXPECTED_SLIDERS[label_start], "%s [min, max, step, value, default]" % label_start)


func test_out_of_range_values_are_corrected_when_the_menu_opens() -> void:
	var game_limits = mod(MOD_ID)
	for setting in OUT_OF_RANGE:
		use_setting(MOD_ID, setting, OUT_OF_RANGE[setting])
	await open_settings()
	for setting in CORRECTED:
		expect_eq(game_limits.call("get_" + setting), CORRECTED[setting], setting)


func test_employee_slider_is_the_game_setting() -> void:
	use_value(gvars.settings, "max_employee_draws", 1025)
	var menu = await open_settings()
	expect_eq(gvars.settings.max_employee_draws, 1025, "a stored 1025 survives opening the menu")
	var ours = setting_control(menu, TAB, "Max Employee")
	var vanilla = menu.max_employee_draws
	vanilla.slider.value = 1075
	expect_eq([gvars.settings.max_employee_draws, ours.slider.value], [1075, 1075.0], "[setting, mod slider] after moving the game's slider")
	ours.slider.value = 4025
	expect_eq([gvars.settings.max_employee_draws, vanilla.slider.value], [4025, 2000.0], "[setting, game slider] after moving the mod's slider past 2000")


static func _label(rows: Dictionary, label_start: String) -> String:
	for label in rows:
		if String(label).begins_with(label_start):
			return label
	return label_start
