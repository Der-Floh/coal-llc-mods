extends PanelContainer
# Dynamically built settings tab for the Game Limits mod.
# Instantiated and added to SettingsMenu.tab_container by settings_2.hooks.gd.

const LOG_NAME := "der_floh-game_limits_mod:Tab"
const MOD_MAIN_PATH := "res://mods-unpacked/der_floh-game_limits_mod/mod_main.gd"

const SLIDER_SCENE = preload("res://scenes/Interfaces/Menus/setting_slider.tscn")
const BOOL_SCENE   = preload("res://scenes/Interfaces/Menus/setting_bool.tscn")
const MAX_EMPLOYEE_DRAWS := 10000

var _max_employees_slider: SettingSlider
var _vanilla_employee_slider: SettingSlider = null
var _syncing := false

@onready var vbox: VBoxContainer = $Margin/VBox


func _ready() -> void:
	var mod_main = load(MOD_MAIN_PATH)
	_add_enabled_toggle(mod_main.get_enabled())

	_add_header("Mortar")
	_add_slider("Max Active Mortars", 50, 10000, 50,
		mod_main.DEFAULT_MAX_MORTARS, mod_main.get_max_mortars(), _on_max_mortars_changed)

	_add_header("Miners / Angels")
	_max_employees_slider = _add_slider("Max Employee Entities Drawn (takes effect on next level load)",
		SettingsMenu.MAX_EMPLOYEE_DRAWS_LOWER_BOUND, MAX_EMPLOYEE_DRAWS, SettingsMenu.MAX_EMPLOYEE_DRAWS_STEP,
		Gvars.settings.DEFAULT_MAX_EMPLOYEE_DRAWS, Gvars.settings.max_employee_draws, _on_max_employees_changed)

	_add_header("Chunk Loading")
	_add_slider("Chunk Load Radius (chunks around each entity)", 1, 100, 1,
		mod_main.DEFAULT_CHUNK_LOAD_RADIUS, mod_main.get_chunk_load_radius(), _on_chunk_radius_changed)
	_add_slider("Chunks Generated Per Frame", 1, 10, 1,
		mod_main.DEFAULT_CHUNKS_PER_FRAME, mod_main.get_chunks_per_frame(), _on_chunks_per_frame_changed)

	_add_header("Electric Pickaxe")
	_add_slider("Max Chain Reaction Tiles", 10, 5000, 10,
		mod_main.DEFAULT_MAX_ELECTRIC_CHAIN, mod_main.get_max_electric_chain(), _on_max_electric_chain_changed)
	_add_slider("Max Visual Arcs (0 = no visuals; does not affect damage)", 0, 1000, 10,
		mod_main.DEFAULT_MAX_ELECTRIC_VISUALS, mod_main.get_max_electric_visuals(), _on_max_electric_visuals_changed)


func _add_enabled_toggle(enabled: bool) -> void:
	var enabled_bool: SettingBool = BOOL_SCENE.instantiate()
	enabled_bool.default = true
	vbox.add_child(enabled_bool)
	enabled_bool.setting_label.text = "Mod Enabled"
	enabled_bool.check_button.button_pressed = enabled
	enabled_bool.new_value.connect(_on_enabled_changed)


func _add_header(title: String) -> void:
	var header := RichTextLabel.new()
	header.bbcode_enabled = true
	header.text = "[b]%s[/b]" % title
	header.fit_content = true
	header.custom_minimum_size = Vector2(0, 28)
	vbox.add_child(header)


# Connected only once range and value are set, so clamping the scene's preset value can't overwrite the config;
# a stored value outside the range is then written back corrected.
func _add_slider(label: String, min_value: float, max_value: float, step: float, default: float, stored: float, on_change: Callable) -> SettingSlider:
	var setting: SettingSlider = SLIDER_SCENE.instantiate()
	setting.default = default
	vbox.add_child(setting)
	setting.setting_label.text = label
	setting.slider.min_value = min_value
	setting.slider.max_value = max_value
	setting.slider.step = step
	setting.slider.value = stored
	setting.new_value.connect(on_change)
	if stored < min_value or stored > max_value:
		on_change.call(setting.slider.value)
	return setting


func _on_max_mortars_changed(new_value: float) -> void:
	load(MOD_MAIN_PATH).set_max_mortars(int(new_value))
	ModLoaderLog.info("Max mortars set to %d" % int(new_value), LOG_NAME)


func link_vanilla_employee_slider(vanilla_slider: SettingSlider) -> void:
	_vanilla_employee_slider = vanilla_slider
	vanilla_slider.new_value.connect(_on_vanilla_employees_changed)


# Called when the user moves the vanilla Gameplay-tab slider.
# Mirrors the new value into our slider (no-op if already equal).
func _on_vanilla_employees_changed(new_value: float) -> void:
	if _syncing:
		return
	_syncing = true
	_max_employees_slider.slider.value = new_value
	_syncing = false


# Called when the user moves our slider.
# Mirrors into the vanilla slider (clamped to its range), then writes
# our intended value to settings so it always wins over the clamped mirror.
func _on_max_employees_changed(new_value: float) -> void:
	if _vanilla_employee_slider != null and not _syncing:
		_syncing = true
		_vanilla_employee_slider.slider.value = clampf(new_value, SettingsMenu.MAX_EMPLOYEE_DRAWS_LOWER_BOUND, SettingsMenu.MAX_EMPLOYEE_DRAWS_UPPER_BOUND)
		_syncing = false
	Gvars.settings.max_employee_draws = int(new_value)
	ModLoaderLog.info("Max employee draws set to %d" % int(new_value), LOG_NAME)


func _on_chunk_radius_changed(new_value: float) -> void:
	load(MOD_MAIN_PATH).set_chunk_load_radius(int(new_value))
	ModLoaderLog.info("Chunk load radius set to %d" % int(new_value), LOG_NAME)


func _on_chunks_per_frame_changed(new_value: float) -> void:
	load(MOD_MAIN_PATH).set_chunks_per_frame(int(new_value))
	ModLoaderLog.info("Chunks per frame set to %d" % int(new_value), LOG_NAME)


func _on_max_electric_chain_changed(new_value: float) -> void:
	load(MOD_MAIN_PATH).set_max_electric_chain(int(new_value))
	ModLoaderLog.info("Max electric chain tiles set to %d" % int(new_value), LOG_NAME)


func _on_max_electric_visuals_changed(new_value: float) -> void:
	load(MOD_MAIN_PATH).set_max_electric_visuals(int(new_value))
	ModLoaderLog.info("Max electric visual arcs set to %d" % int(new_value), LOG_NAME)


func _on_enabled_changed(value: bool) -> void:
	load(MOD_MAIN_PATH).set_enabled(value)
	ModLoaderLog.info("Mod enabled set to %s" % str(value), LOG_NAME)
