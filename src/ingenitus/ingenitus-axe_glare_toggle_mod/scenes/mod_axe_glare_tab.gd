extends PanelContainer
# Dynamically built settings tab for the Axe Glare Toggle mod.
# Instantiated and added to SettingsMenu.tab_container by settings_2.hooks.gd.

const LOG_NAME := "ingenitus-axe_glare_toggle_mod:Tab"
const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-axe_glare_toggle_mod/mod_main.gd"

const BOOL_SCENE = preload("res://scenes/Interfaces/Menus/setting_bool.tscn")

@onready var vbox: VBoxContainer = $Margin/VBox


func _ready() -> void:
	var mod_main = load(MOD_MAIN_PATH)

	var enabled_bool: SettingBool = BOOL_SCENE.instantiate()
	enabled_bool.default = true
	vbox.add_child(enabled_bool)
	enabled_bool.setting_label.text = "Mod Enabled"
	enabled_bool.check_button.button_pressed = mod_main.get_enabled()
	enabled_bool.new_value.connect(_on_enabled_changed)

	var glare_bool: SettingBool = BOOL_SCENE.instantiate()
	glare_bool.default = false
	vbox.add_child(glare_bool)
	# Configure AFTER add_child so @onready vars are initialised
	glare_bool.setting_label.text = "Show axe / battleaxe spin glare"
	glare_bool.check_button.button_pressed = mod_main.get_show_glare()
	glare_bool.new_value.connect(_on_show_glare_changed)


func _on_show_glare_changed(value: bool) -> void:
	load(MOD_MAIN_PATH).set_show_glare(value)
	ModLoaderLog.info("Show glare set to %s" % str(value), LOG_NAME)


func _on_enabled_changed(value: bool) -> void:
	load(MOD_MAIN_PATH).set_enabled(value)
	ModLoaderLog.info("Mod enabled set to %s" % str(value), LOG_NAME)
