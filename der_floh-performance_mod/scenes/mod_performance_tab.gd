extends PanelContainer
# Dynamically built settings tab for the Performance mod.
# Instantiated and added to SettingsMenu.tab_container by settings_2.hooks.gd.

const LOG_NAME := "der_floh-performance_mod:Tab"

const BOOL_SCENE = preload("res://scenes/Interfaces/Menus/setting_bool.tscn")

@onready var vbox: VBoxContainer = $Margin/VBox


func _ready() -> void:
	var mod_main = load("res://mods-unpacked/der_floh-performance_mod/mod_main.gd")

	# --- Section: Debug ---
	var debug_header := RichTextLabel.new()
	debug_header.bbcode_enabled = true
	debug_header.text = "[b]Debug[/b]"
	debug_header.fit_content = true
	debug_header.custom_minimum_size = Vector2(0, 28)
	vbox.add_child(debug_header)

	var debug_bool: SettingBool = BOOL_SCENE.instantiate()
	debug_bool.default = false
	vbox.add_child(debug_bool)
	# Configure AFTER add_child so @onready vars are initialised
	debug_bool.setting_label.text = "Debug Logging (prints chunk/electric stats to modloader.log)"
	debug_bool.check_button.button_pressed = mod_main.get_debug_logging()
	debug_bool.new_value.connect(_on_debug_logging_changed)


func _on_debug_logging_changed(value: bool) -> void:
	var mod_main = load("res://mods-unpacked/der_floh-performance_mod/mod_main.gd")
	mod_main.set_debug_logging(value)
	mod_main._debug = value
	ModLoaderLog.info("Debug logging set to %s" % str(value), LOG_NAME)
