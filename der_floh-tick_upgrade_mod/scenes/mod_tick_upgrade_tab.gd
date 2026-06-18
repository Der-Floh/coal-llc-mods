extends PanelContainer
# Dynamically built settings tab for the Tick Upgrade mod.
# Instantiated and added to SettingsMenu.tab_container by settings_2.hooks.gd.

const LOG_NAME := "der_floh-tick_upgrade_mod:Tab"

const BOOL_SCENE = preload("res://scenes/Interfaces/Menus/setting_bool.tscn")

@onready var vbox: VBoxContainer = $Margin/VBox


func _ready() -> void:
	var mod_main = load("res://mods-unpacked/der_floh-tick_upgrade_mod/mod_main.gd")

	var enabled_bool: SettingBool = BOOL_SCENE.instantiate()
	enabled_bool.default = true
	vbox.add_child(enabled_bool)
	enabled_bool.setting_label.text = "Mod Enabled"
	enabled_bool.check_button.button_pressed = mod_main.get_enabled()
	enabled_bool.new_value.connect(_on_enabled_changed)

	# --- Section: Distant Tile Ticking ---
	var header := RichTextLabel.new()
	header.bbcode_enabled = true
	header.text = "[b]Distant Tile Ticking[/b]"
	header.fit_content = true
	header.custom_minimum_size = Vector2(0, 28)
	vbox.add_child(header)

	var distant_bool: SettingBool = BOOL_SCENE.instantiate()
	distant_bool.default = true
	vbox.add_child(distant_bool)
	# Configure AFTER add_child so @onready vars are initialised
	distant_bool.setting_label.text          = "Always tick distant (out-of-range) tiles"
	distant_bool.check_button.button_pressed = mod_main.get_always_tick_distant()
	distant_bool.new_value.connect(_on_always_tick_distant_changed)

	# --- Section: Tick Speed ---
	var speed_header := RichTextLabel.new()
	speed_header.bbcode_enabled = true
	speed_header.text = "[b]Tick Speed[/b]"
	speed_header.fit_content = true
	speed_header.custom_minimum_size = Vector2(0, 28)
	vbox.add_child(speed_header)

	var preserve_bool: SettingBool = BOOL_SCENE.instantiate()
	preserve_bool.default = true
	vbox.add_child(preserve_bool)
	# Configure AFTER add_child so @onready vars are initialised
	preserve_bool.setting_label.text          = "Preserve effect duration when tick speed is increased"
	preserve_bool.check_button.button_pressed = mod_main.get_preserve_duration()
	preserve_bool.new_value.connect(_on_preserve_duration_changed)


func _on_always_tick_distant_changed(value: bool) -> void:
	var mod_main = load("res://mods-unpacked/der_floh-tick_upgrade_mod/mod_main.gd")
	mod_main.set_always_tick_distant(value)
	ModLoaderLog.info("Always tick distant set to %s" % str(value), LOG_NAME)


func _on_preserve_duration_changed(value: bool) -> void:
	var mod_main = load("res://mods-unpacked/der_floh-tick_upgrade_mod/mod_main.gd")
	mod_main.set_preserve_duration(value)
	ModLoaderLog.info("Preserve duration set to %s" % str(value), LOG_NAME)


func _on_enabled_changed(value: bool) -> void:
	var mod_main = load("res://mods-unpacked/der_floh-tick_upgrade_mod/mod_main.gd")
	mod_main.set_enabled(value)
	ModLoaderLog.info("Mod enabled set to %s" % str(value), LOG_NAME)

