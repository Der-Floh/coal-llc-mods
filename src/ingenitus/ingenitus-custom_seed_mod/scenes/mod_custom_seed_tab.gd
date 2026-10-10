extends PanelContainer
# Dynamically built settings tab for the Custom Seed mod.
# Instantiated and added to SettingsMenu.tab_container by settings_2.hooks.gd.

const LOG_NAME := "ingenitus-custom_seed_mod:Tab"
const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-custom_seed_mod/mod_main.gd"

const BOOL_SCENE = preload("res://scenes/Interfaces/Menus/setting_bool.tscn")
const MAX_SEED_DIGITS := 9  # stays inside a 32-bit int

@onready var vbox: VBoxContainer = $Margin/VBox


func _ready() -> void:
	var mod_main = load(MOD_MAIN_PATH)

	var enabled_bool: SettingBool = BOOL_SCENE.instantiate()
	enabled_bool.default = true
	vbox.add_child(enabled_bool)
	enabled_bool.setting_label.text = "Mod Enabled"
	enabled_bool.check_button.button_pressed = mod_main.get_enabled()
	enabled_bool.new_value.connect(_on_enabled_changed)

	var note := RichTextLabel.new()
	note.bbcode_enabled = true
	note.text = "The same seed builds the same mine however you explore it. 0 = random (vanilla). Takes effect from the next mining day."
	note.fit_content = true
	note.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(note)

	_add_seed_row(mod_main)

	var same_bool: SettingBool = BOOL_SCENE.instantiate()
	same_bool.default = false
	vbox.add_child(same_bool)
	# Configure AFTER add_child so @onready vars are initialised
	same_bool.setting_label.text = "Same mine every day (off = a new seeded mine each day)"
	same_bool.check_button.button_pressed = mod_main.get_same_every_day()
	same_bool.new_value.connect(_on_same_every_day_changed)


func _add_seed_row(mod_main) -> void:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
	row.custom_minimum_size = Vector2(0, 36)
	vbox.add_child(row)

	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.text = "World Seed"
	label.fit_content = true
	label.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(label)

	var edit := LineEdit.new()
	edit.custom_minimum_size = Vector2(200, 0)
	edit.placeholder_text = "0 = random"
	var current: int = mod_main.get_seed()
	edit.text = "" if current == 0 else str(current)
	row.add_child(edit)
	edit.text_changed.connect(_on_seed_text_changed.bind(edit))


func _on_seed_text_changed(new_text: String, edit: LineEdit) -> void:
	var digits := ""
	for c in new_text:
		if c >= "0" and c <= "9":
			digits += c
	digits = digits.left(MAX_SEED_DIGITS)
	if digits != new_text:
		edit.text = digits
		edit.caret_column = digits.length()
	var value: int = int(digits) if digits != "" else 0
	load(MOD_MAIN_PATH).set_seed(value)
	ModLoaderLog.info("World seed set to %d" % value, LOG_NAME)


func _on_same_every_day_changed(value: bool) -> void:
	load(MOD_MAIN_PATH).set_same_every_day(value)
	ModLoaderLog.info("Same mine every day set to %s" % str(value), LOG_NAME)


func _on_enabled_changed(value: bool) -> void:
	load(MOD_MAIN_PATH).set_enabled(value)
	ModLoaderLog.info("Mod enabled set to %s" % str(value), LOG_NAME)
