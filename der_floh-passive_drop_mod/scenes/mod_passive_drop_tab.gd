extends PanelContainer
# Dynamically built settings tab for the Passive Drop mod.
# Instantiated and added to SettingsMenu.tab_container by settings_2.hooks.gd.

const LOG_NAME := "der_floh-passive_drop_mod:Tab"

const BOOL_SCENE   = preload("res://scenes/Interfaces/Menus/setting_bool.tscn")
const SLIDER_SCENE = preload("res://scenes/Interfaces/Menus/setting_slider.tscn")

@onready var vbox: VBoxContainer = $Margin/Scroll/VBox


func _ready() -> void:
	var mod_main = load("res://mods-unpacked/der_floh-passive_drop_mod/mod_main.gd")

	# --- Section: Coal ---
	_add_section("Coal")
	_add_chance_row("coal",         "Coal",         mod_main)

	# --- Section: Minerals ---
	_add_section("Minerals")
	_add_chance_row("copper",       "Copper",        mod_main)
	_add_chance_row("iron",         "Iron",          mod_main)
	_add_chance_row("silver",       "Silver",         mod_main)
	_add_chance_row("gold",         "Gold",          mod_main)

	# --- Section: Gems ---
	_add_section("Gems")
	_add_chance_row("amethyst",     "Amethyst",       mod_main)
	_add_chance_row("sapphire",     "Sapphire",       mod_main)
	_add_chance_row("emerald",      "Emerald",        mod_main)
	_add_chance_row("ruby",         "Ruby",           mod_main)
	_add_chance_row("diamond",      "Diamond",        mod_main)
	_add_chance_row("pink_diamond", "Pink Diamond",   mod_main)
	_add_chance_row("spinel",       "Spinel",         mod_main)
	_add_chance_row("uranium",      "Uranium",        mod_main)
	_add_chance_row("moonstone",    "Moonstone",      mod_main)
	_add_chance_row("onyx",         "Onyx",           mod_main)

	# --- Section: Other Blocks ---
	_add_section("Other Blocks")
	_add_chance_row("non_ore",      "Non-Ore Blocks", mod_main, mod_main.DEFAULT_CHANCE_NON_ORE)

	# --- Section: Chests ---
	_add_section("Chests")

	var weapons_bool: SettingBool = BOOL_SCENE.instantiate()
	weapons_bool.default = bool(mod_main.DEFAULT_GOLDEN_WEAPONS_ENABLED)
	weapons_bool.new_value.connect(_on_golden_weapons_changed)
	vbox.add_child(weapons_bool)
	weapons_bool.setting_label.text = "Weapon Drops from Chests"
	weapons_bool.check_button.button_pressed = mod_main.get_golden_weapons_enabled()

	var chests_bool: SettingBool = BOOL_SCENE.instantiate()
	chests_bool.default = bool(mod_main.DEFAULT_CHEST_GENERATION_ENABLED)
	chests_bool.new_value.connect(_on_chest_generation_changed)
	vbox.add_child(chests_bool)
	chests_bool.setting_label.text = "Chest Generation (takes effect on next level load)"
	chests_bool.check_button.button_pressed = mod_main.get_chest_generation_enabled()

	# --- Section: Behaviour ---
	_add_section("Behaviour")

	var auto_collect_bool: SettingBool = BOOL_SCENE.instantiate()
	auto_collect_bool.default = bool(mod_main.DEFAULT_AUTO_COLLECT_PASSIVES)
	auto_collect_bool.new_value.connect(_on_auto_collect_passives_changed)
	vbox.add_child(auto_collect_bool)
	# When enabled, triggers the passive chooser directly on drop instead of
	# spawning a world item — seamlessly integrates with NanobotZ-AutoPassiveChooser.
	auto_collect_bool.setting_label.text = "Auto-Collect Dropped Passives"
	auto_collect_bool.check_button.button_pressed = mod_main.get_auto_collect_passives()


func _add_section(title: String) -> void:
	var header := RichTextLabel.new()
	header.bbcode_enabled = true
	header.text = "[b]%s[/b]" % title
	header.fit_content = true
	header.custom_minimum_size = Vector2(0, 28)
	vbox.add_child(header)


func _add_chance_row(key: String, display_name: String, mod_main, default_chance: int = -1) -> void:
	var slider_row: SettingSlider = SLIDER_SCENE.instantiate()
	# Use per-ore default from CHANCE_DEFAULTS when not explicitly overridden
	var resolved_default: int = default_chance if default_chance >= 0 else mod_main.CHANCE_DEFAULTS.get(key, 0)
	slider_row.default = float(resolved_default)
	# add_child triggers _ready() which populates @onready vars — must come before any property access
	vbox.add_child(slider_row)
	slider_row.setting_label.text = display_name
	slider_row.slider.min_value = 0
	slider_row.slider.max_value = 100
	slider_row.slider.step = 1
	# Set value BEFORE connecting new_value so startup doesn't write to config.
	# This triggers SettingSlider._on_slider_value_changed → value_label becomes "X.00";
	# override it immediately after with integer % format.
	slider_row.slider.value = float(mod_main.get_chance_for_key(key))
	slider_row.value_label.text = "%d%%" % int(slider_row.slider.value)
	slider_row.new_value.connect(func(val: float) -> void:
		mod_main.set_chance_for_key(key, int(val))
		slider_row.value_label.text = "%d%%" % int(val)
	)


func _on_golden_weapons_changed(value: bool) -> void:
	var mod_main = load("res://mods-unpacked/der_floh-passive_drop_mod/mod_main.gd")
	mod_main.set_golden_weapons_enabled(value)


func _on_chest_generation_changed(value: bool) -> void:
	var mod_main = load("res://mods-unpacked/der_floh-passive_drop_mod/mod_main.gd")
	mod_main.set_chest_generation_enabled(value)


func _on_auto_collect_passives_changed(value: bool) -> void:
	var mod_main = load("res://mods-unpacked/der_floh-passive_drop_mod/mod_main.gd")
	mod_main.set_auto_collect_passives(value)
