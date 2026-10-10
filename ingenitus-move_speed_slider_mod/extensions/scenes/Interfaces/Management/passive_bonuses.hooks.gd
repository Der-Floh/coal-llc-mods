extends Object

# Adds a Walk Speed row with a slider to the passive bonuses panel (Tab), styled
# like vanilla's movement sliders. It is always shown: base sprint is already
# faster than base walk, so there is a range to choose from from the start.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-move_speed_slider_mod/mod_main.gd"


func refresh(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	var mod_main = load(MOD_MAIN_PATH)
	if not mod_main._enabled:
		return
	var panel := chain.reference_object as PassiveBonuses
	panel.add_child(_walk_slider(mod_main))


static func _walk_slider(mod_main) -> HBoxContainer:
	var max_bonus: float = mod_main.max_walk_bonus()
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var label := RichTextLabel.new()
	label.fit_content = true
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.text = "Walk Speed (up to sprint) +" + str(roundi(max_bonus * 100)) + "%"
	var slider := HSlider.new()
	slider.name = "IngenitusWalkSpeedSlider"
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.min_value = 0.0
	slider.max_value = max_bonus
	# No snapping: a fractional sprint bonus gives a maximum such as 0.575, which a
	# 0.01 step could never reach.
	slider.step = 0.0
	slider.set_value_no_signal(minf(mod_main.walk_bonus, max_bonus))
	var value_label := RichTextLabel.new()
	value_label.fit_content = true
	value_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	value_label.text = str(roundi(slider.value * 100)) + "%"
	slider.value_changed.connect(func(v: float) -> void:
		mod_main.set_walk_bonus(v)
		value_label.text = str(roundi(v * 100)) + "%")
	row.add_child(label)
	row.add_child(slider)
	row.add_child(value_label)
	return row
