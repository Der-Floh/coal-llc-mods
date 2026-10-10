extends PanelContainer
# Dynamically built settings tab for the Chest QoL mod.
# Instantiated and added to SettingsMenu.tab_container by settings_2.hooks.gd.

const LOG_NAME := "ingenitus-chest_qol_mod:Tab"
const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-chest_qol_mod/mod_main.gd"

const BOOL_SCENE = preload("res://scenes/Interfaces/Menus/setting_bool.tscn")

@onready var vbox: VBoxContainer = $Margin/VBox


func _ready() -> void:
	var mod_main = load(MOD_MAIN_PATH)
	var data: Dictionary = mod_main.get_config().data

	var enabled_bool: SettingBool = BOOL_SCENE.instantiate()
	enabled_bool.default = true
	vbox.add_child(enabled_bool)
	enabled_bool.setting_label.text = "Mod Enabled"
	enabled_bool.check_button.button_pressed = mod_main.get_enabled()
	enabled_bool.new_value.connect(_on_enabled_changed)

	for key in mod_main.OPTIONS:
		var option_bool: SettingBool = BOOL_SCENE.instantiate()
		option_bool.default = true
		vbox.add_child(option_bool)
		# Configure AFTER add_child so @onready vars are initialised
		option_bool.setting_label.text = mod_main.OPTIONS[key]
		option_bool.check_button.button_pressed = bool(data.get(key, true))
		option_bool.new_value.connect(_on_option_changed.bind(key))


func _on_option_changed(value: bool, key: String) -> void:
	load(MOD_MAIN_PATH).set_option(key, value)
	ModLoaderLog.info("%s set to %s" % [key, str(value)], LOG_NAME)


func _on_enabled_changed(value: bool) -> void:
	load(MOD_MAIN_PATH).set_enabled(value)
	ModLoaderLog.info("Mod enabled set to %s" % str(value), LOG_NAME)
