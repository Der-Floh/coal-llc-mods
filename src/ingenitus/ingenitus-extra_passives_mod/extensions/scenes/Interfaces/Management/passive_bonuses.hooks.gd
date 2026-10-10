extends Object

# Lists the new passives in the passive bonuses panel (Tab), like vanilla's rows.
# Bomb radius also gets a dial-back slider once earned, like vanilla's movement
# sliders: bombs use the slider value, never more than the earned value.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-extra_passives_mod/mod_main.gd"


func refresh(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	var panel := chain.reference_object as PassiveBonuses
	var mod_main = load(MOD_MAIN_PATH)
	if not mod_main.get_enabled():
		return
	for key in mod_main.PASSIVES:
		var earned: float = mod_main.levels.get(key, 0.0)
		if earned == 0.0:
			continue
		if key == "bomb_radius":
			panel.add_child(_bomb_slider(mod_main, earned))
		else:
			var label := RichTextLabel.new()
			label.text = mod_main.label_text(key, earned)
			label.fit_content = true
			panel.add_child(label)


static func _bomb_slider(mod_main, earned: float) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var label := RichTextLabel.new()
	label.fit_content = true
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.text = mod_main.label_text("bomb_radius", earned)
	var slider := HSlider.new()
	slider.name = "IngenitusBombRadiusSlider"
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.min_value = 0.0
	slider.max_value = earned
	slider.step = 0.01
	slider.set_value_no_signal(minf(mod_main.adjusted_bomb_radius, earned))
	var value_label := RichTextLabel.new()
	value_label.fit_content = true
	value_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	value_label.text = str(roundi(slider.value * 100)) + "%"
	slider.value_changed.connect(func(v: float) -> void:
		mod_main.adjusted_bomb_radius = v
		value_label.text = str(roundi(v * 100)) + "%")
	row.add_child(label)
	row.add_child(slider)
	row.add_child(value_label)
	return row
