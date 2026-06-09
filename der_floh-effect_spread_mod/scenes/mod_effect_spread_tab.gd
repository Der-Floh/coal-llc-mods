extends PanelContainer
# Dynamically built settings tab for the Effect Spread mod.
# Instantiated and added to SettingsMenu.tab_container by settings_2.hooks.gd.

const LOG_NAME := "der_floh-effect_spread_mod:Tab"

const SLIDER_SCENE = preload("res://scenes/Interfaces/Menus/setting_slider.tscn")
const BOOL_SCENE   = preload("res://scenes/Interfaces/Menus/setting_bool.tscn")

@onready var vbox: VBoxContainer = $Margin/VBox


func _ready() -> void:
	var mod_main = load("res://mods-unpacked/der_floh-effect_spread_mod/mod_main.gd")

	# ------------------------------------------------------------------ Spread
	var spread_header := RichTextLabel.new()
	spread_header.bbcode_enabled = true
	spread_header.text = "[b]Spread[/b]"
	spread_header.fit_content = true
	spread_header.custom_minimum_size = Vector2(0, 28)
	vbox.add_child(spread_header)

	var radius_slider: SettingSlider = SLIDER_SCENE.instantiate()
	radius_slider.default = mod_main.DEFAULT_SPREAD_RADIUS
	vbox.add_child(radius_slider)
	# Configure AFTER add_child so @onready vars are initialised
	radius_slider.setting_label.text = "Spread Radius (tiles around destroyed ore)"
	radius_slider.slider.min_value   = 1
	radius_slider.slider.max_value   = 20
	radius_slider.slider.step        = 1
	radius_slider.slider.value       = mod_main.get_spread_radius()
	# Connect AFTER setting value to avoid firing the callback during setup
	radius_slider.new_value.connect(_on_spread_radius_changed)

	# ------------------------------------------------------------------- Ticks
	var ticks_header := RichTextLabel.new()
	ticks_header.bbcode_enabled = true
	ticks_header.text = "[b]Ticks[/b]"
	ticks_header.fit_content = true
	ticks_header.custom_minimum_size = Vector2(0, 28)
	vbox.add_child(ticks_header)

	var inherit_bool: SettingBool = BOOL_SCENE.instantiate()
	inherit_bool.default = mod_main.DEFAULT_INHERIT_TICKS
	vbox.add_child(inherit_bool)
	# Configure AFTER add_child so @onready vars are initialised
	inherit_bool.setting_label.text          = "Inherit remaining ticks from destroyed ore"
	inherit_bool.check_button.button_pressed = mod_main.get_inherit_ticks()
	inherit_bool.new_value.connect(_on_inherit_ticks_changed)

	var fresh_slider: SettingSlider = SLIDER_SCENE.instantiate()
	fresh_slider.default = mod_main.DEFAULT_FRESH_TICKS
	vbox.add_child(fresh_slider)
	# Configure AFTER add_child so @onready vars are initialised
	fresh_slider.setting_label.text = "Fresh tick count (when not inheriting)"
	fresh_slider.slider.min_value   = 1
	fresh_slider.slider.max_value   = 50
	fresh_slider.slider.step        = 1
	fresh_slider.slider.value       = mod_main.get_fresh_ticks()
	fresh_slider.new_value.connect(_on_fresh_ticks_changed)


func _on_spread_radius_changed(value: float) -> void:
	var mod_main = load("res://mods-unpacked/der_floh-effect_spread_mod/mod_main.gd")
	mod_main.set_spread_radius(value)
	ModLoaderLog.info("Spread radius set to %d" % int(value), LOG_NAME)


func _on_inherit_ticks_changed(value: bool) -> void:
	var mod_main = load("res://mods-unpacked/der_floh-effect_spread_mod/mod_main.gd")
	mod_main.set_inherit_ticks(value)
	ModLoaderLog.info("Inherit ticks set to %s" % str(value), LOG_NAME)


func _on_fresh_ticks_changed(value: float) -> void:
	var mod_main = load("res://mods-unpacked/der_floh-effect_spread_mod/mod_main.gd")
	mod_main.set_fresh_ticks(value)
	ModLoaderLog.info("Fresh ticks set to %d" % int(value), LOG_NAME)


