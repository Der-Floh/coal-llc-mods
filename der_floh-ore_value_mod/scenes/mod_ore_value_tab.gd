extends PanelContainer
# Dynamically built settings tab for the Ore Value mod.
# Instantiated and added to SettingsMenu.tab_container by settings_2.hooks.gd.

const LOG_NAME := "der_floh-ore_value_mod:Tab"

const BOOL_SCENE = preload("res://scenes/Interfaces/Menus/setting_bool.tscn")

@onready var vbox: VBoxContainer = $Margin/Scroll/VBox


func _ready() -> void:
	var mod_main := load("res://mods-unpacked/der_floh-ore_value_mod/mod_main.gd")

	var enabled_bool: SettingBool = BOOL_SCENE.instantiate()
	enabled_bool.default = true
	vbox.add_child(enabled_bool)
	enabled_bool.setting_label.text = "Mod Enabled"
	enabled_bool.check_button.button_pressed = mod_main.get_enabled()
	enabled_bool.new_value.connect(_on_enabled_changed)

	_add_section("Coal")
	_add_ore_row("Coal", "Coal", mod_main)

	_add_section("Minerals")
	_add_ore_row("CopperOre", "Copper Ore", mod_main)
	_add_ore_row("IronOre",   "Iron Ore",   mod_main)
	_add_ore_row("SilverOre", "Silver Ore", mod_main)
	_add_ore_row("GoldOre",   "Gold Ore",   mod_main)

	_add_section("Gems")
	_add_ore_row("Amethyst",    "Amethyst",     mod_main)
	_add_ore_row("Sapphire",    "Sapphire",     mod_main)
	_add_ore_row("Emerald",     "Emerald",      mod_main)
	_add_ore_row("Ruby",        "Ruby",         mod_main)
	_add_ore_row("Diamond",     "Diamond",      mod_main)
	_add_ore_row("PinkDiamond", "Pink Diamond", mod_main)
	_add_ore_row("spinel",      "Spinel",       mod_main)
	_add_ore_row("uranium",     "Uranium",      mod_main)
	_add_ore_row("moonstone",   "Moonstone",    mod_main)
	_add_ore_row("onyx",        "Onyx",         mod_main)


func _add_section(title: String) -> void:
	var header := RichTextLabel.new()
	header.bbcode_enabled = true
	header.text = "[b]%s[/b]" % title
	header.fit_content = true
	header.custom_minimum_size = Vector2(0, 28)
	vbox.add_child(header)


func _on_enabled_changed(value: bool) -> void:
	var mod_main := load("res://mods-unpacked/der_floh-ore_value_mod/mod_main.gd")
	mod_main.set_enabled(value)
	ModLoaderLog.info("Mod enabled set to %s" % str(value), LOG_NAME)


func _add_ore_row(item_id: String, display_name: String, mod_main) -> void:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
	row.custom_minimum_size = Vector2(0, 36)
	vbox.add_child(row)

	# RichTextLabel uses the game's themed font, giving the same size and style as
	# NanobotZ's passive list rows instead of the smaller default Label font.
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.text = display_name
	label.fit_content = true
	label.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(label)

	var spinbox := SpinBox.new()
	spinbox.min_value = 0.0
	spinbox.max_value = 1e15  # 1 quadrillion — upper bound for any sane multiplier
	spinbox.step = 1.0
	spinbox.custom_minimum_size = Vector2(200, 0)
	# Set value BEFORE connecting value_changed so startup doesn't write to config.
	spinbox.value = mod_main.get_multiplier(item_id)
	row.add_child(spinbox)
	spinbox.value_changed.connect(func(val: float) -> void: mod_main.set_multiplier(item_id, val))


