extends PanelContainer
# Dynamically built settings tab for the Game Limits mod.
# Instantiated and added to SettingsMenu.tab_container by settings_2.hooks.gd.

const LOG_NAME := "der_floh-game_limits_mod:Tab"

const SLIDER_SCENE = preload("res://scenes/Interfaces/Menus/setting_slider.tscn")

var _max_employees_slider: SettingSlider
var _vanilla_employee_slider: SettingSlider = null
var _syncing := false

@onready var vbox: VBoxContainer = $Margin/VBox


func _ready() -> void:
	var mod_main = load("res://mods-unpacked/der_floh-game_limits_mod/mod_main.gd")

	# --- Section: Mortar ---
	var mortar_header := RichTextLabel.new()
	mortar_header.bbcode_enabled = true
	mortar_header.text = "[b]Mortar[/b]"
	mortar_header.fit_content = true
	mortar_header.custom_minimum_size = Vector2(0, 28)
	vbox.add_child(mortar_header)

	var max_mortars_slider: SettingSlider = SLIDER_SCENE.instantiate()
	max_mortars_slider.default = mod_main.DEFAULT_MAX_MORTARS
	max_mortars_slider.new_value.connect(_on_max_mortars_changed)
	vbox.add_child(max_mortars_slider)
	# Configure AFTER add_child so @onready vars are initialised
	max_mortars_slider.setting_label.text = "Max Active Mortars"
	max_mortars_slider.slider.min_value = 50
	max_mortars_slider.slider.max_value = 10000
	max_mortars_slider.slider.step = 50
	max_mortars_slider.slider.value = mod_main.get_max_mortars()

	# --- Section: Miners / Angels ---
	var miners_header := RichTextLabel.new()
	miners_header.bbcode_enabled = true
	miners_header.text = "[b]Miners / Angels[/b]"
	miners_header.fit_content = true
	miners_header.custom_minimum_size = Vector2(0, 28)
	vbox.add_child(miners_header)

	_max_employees_slider = SLIDER_SCENE.instantiate()
	_max_employees_slider.default = 500
	_max_employees_slider.new_value.connect(_on_max_employees_changed)
	vbox.add_child(_max_employees_slider)
	_max_employees_slider.setting_label.text = "Max Employee Entities Drawn (takes effect on next level load)"
	_max_employees_slider.slider.min_value = 50
	_max_employees_slider.slider.max_value = 10000
	_max_employees_slider.slider.step = 50
	_max_employees_slider.slider.value = Gvars.settings.max_employee_draws

	# --- Section: Chunk Loading ---
	var chunk_header := RichTextLabel.new()
	chunk_header.bbcode_enabled = true
	chunk_header.text = "[b]Chunk Loading[/b]"
	chunk_header.fit_content = true
	chunk_header.custom_minimum_size = Vector2(0, 28)
	vbox.add_child(chunk_header)

	var chunk_radius_slider: SettingSlider = SLIDER_SCENE.instantiate()
	chunk_radius_slider.default = mod_main.DEFAULT_CHUNK_LOAD_RADIUS
	chunk_radius_slider.new_value.connect(_on_chunk_radius_changed)
	vbox.add_child(chunk_radius_slider)
	chunk_radius_slider.setting_label.text = "Chunk Load Radius (chunks around each entity)"
	chunk_radius_slider.slider.min_value = 1
	chunk_radius_slider.slider.max_value = 100
	chunk_radius_slider.slider.step = 1
	chunk_radius_slider.slider.value = mod_main.get_chunk_load_radius()

	var chunks_per_frame_slider: SettingSlider = SLIDER_SCENE.instantiate()
	chunks_per_frame_slider.default = mod_main.DEFAULT_CHUNKS_PER_FRAME
	vbox.add_child(chunks_per_frame_slider)
	chunks_per_frame_slider.setting_label.text = "Chunks Generated Per Frame"
	chunks_per_frame_slider.slider.min_value = 1
	# max_value < tscn default of 50 — connect signal AFTER setting range+value to
	# prevent the clamp from 50→10 firing value_changed and overwriting the config.
	chunks_per_frame_slider.slider.max_value = 10
	chunks_per_frame_slider.slider.step = 1
	chunks_per_frame_slider.slider.value = mod_main.get_chunks_per_frame()
	chunks_per_frame_slider.new_value.connect(_on_chunks_per_frame_changed)

	# --- Section: Electric Pickaxe ---
	var electric_header := RichTextLabel.new()
	electric_header.bbcode_enabled = true
	electric_header.text = "[b]Electric Pickaxe[/b]"
	electric_header.fit_content = true
	electric_header.custom_minimum_size = Vector2(0, 28)
	vbox.add_child(electric_header)

	var electric_chain_slider: SettingSlider = SLIDER_SCENE.instantiate()
	electric_chain_slider.default = mod_main.DEFAULT_MAX_ELECTRIC_CHAIN
	electric_chain_slider.new_value.connect(_on_max_electric_chain_changed)
	vbox.add_child(electric_chain_slider)
	electric_chain_slider.setting_label.text = "Max Chain Reaction Tiles"
	electric_chain_slider.slider.min_value = 10
	electric_chain_slider.slider.max_value = 5000
	electric_chain_slider.slider.step = 10
	electric_chain_slider.slider.value = mod_main.get_max_electric_chain()

	var electric_visuals_slider: SettingSlider = SLIDER_SCENE.instantiate()
	electric_visuals_slider.default = mod_main.DEFAULT_MAX_ELECTRIC_VISUALS
	electric_visuals_slider.new_value.connect(_on_max_electric_visuals_changed)
	vbox.add_child(electric_visuals_slider)
	electric_visuals_slider.setting_label.text = "Max Visual Arcs (0 = no visuals; does not affect damage)"
	electric_visuals_slider.slider.min_value = 0
	electric_visuals_slider.slider.max_value = 1000
	electric_visuals_slider.slider.step = 10
	electric_visuals_slider.slider.value = mod_main.get_max_electric_visuals()


func _on_max_mortars_changed(new_value: float) -> void:
	var mod_main = load("res://mods-unpacked/der_floh-game_limits_mod/mod_main.gd")
	mod_main.set_max_mortars(int(new_value))
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
# Mirrors into the vanilla slider (clamped to its 50–2000 range), then writes
# our intended value to settings so it always wins over the clamped mirror.
func _on_max_employees_changed(new_value: float) -> void:
	if _vanilla_employee_slider != null and not _syncing:
		_syncing = true
		_vanilla_employee_slider.slider.value = clampf(new_value, 50.0, 2000.0)
		_syncing = false
	Gvars.settings.max_employee_draws = int(new_value)
	ModLoaderLog.info("Max employee draws set to %d" % int(new_value), LOG_NAME)


func _on_chunk_radius_changed(new_value: float) -> void:
	var mod_main = load("res://mods-unpacked/der_floh-game_limits_mod/mod_main.gd")
	mod_main.set_chunk_load_radius(int(new_value))
	ModLoaderLog.info("Chunk load radius set to %d" % int(new_value), LOG_NAME)


func _on_chunks_per_frame_changed(new_value: float) -> void:
	var mod_main = load("res://mods-unpacked/der_floh-game_limits_mod/mod_main.gd")
	mod_main.set_chunks_per_frame(int(new_value))
	ModLoaderLog.info("Chunks per frame set to %d" % int(new_value), LOG_NAME)


func _on_max_electric_chain_changed(new_value: float) -> void:
	var mod_main = load("res://mods-unpacked/der_floh-game_limits_mod/mod_main.gd")
	mod_main.set_max_electric_chain(int(new_value))
	ModLoaderLog.info("Max electric chain tiles set to %d" % int(new_value), LOG_NAME)


func _on_max_electric_visuals_changed(new_value: float) -> void:
	var mod_main = load("res://mods-unpacked/der_floh-game_limits_mod/mod_main.gd")
	mod_main.set_max_electric_visuals(int(new_value))
	ModLoaderLog.info("Max electric visual arcs set to %d" % int(new_value), LOG_NAME)
