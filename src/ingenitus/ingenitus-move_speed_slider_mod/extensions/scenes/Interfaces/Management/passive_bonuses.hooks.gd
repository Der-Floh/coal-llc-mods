extends Object

# Adds a Walk Speed row with a slider to the passive bonuses panel (Tab), styled
# like vanilla's movement sliders. It is always shown: base sprint is already
# faster than base walk, so there is a range to choose from from the start.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-move_speed_slider_mod/mod_main.gd"
const SPRINT_PASSIVE := "player_sprint_speed"


func refresh(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	var mod_main = load(MOD_MAIN_PATH)
	if not mod_main._enabled:
		return
	var panel := chain.reference_object as PassiveBonuses
	var row := _walk_slider(mod_main)
	panel.add_child(row)
	var sprint_row := _sprint_adjuster(panel)
	if sprint_row and sprint_row.h_slider:
		sprint_row.h_slider.value_changed.connect(func(_value: float) -> void: _show_limit(row, mod_main))


static func _walk_slider(mod_main) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var label := RichTextLabel.new()
	label.fit_content = true
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	var slider := HSlider.new()
	slider.name = "IngenitusWalkSpeedSlider"
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.min_value = 0.0
	# No snapping: a fractional sprint bonus gives a maximum such as 0.575, which a
	# 0.01 step could never reach.
	slider.step = 0.0
	var value_label := RichTextLabel.new()
	value_label.fit_content = true
	value_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	slider.value_changed.connect(func(v: float) -> void:
		mod_main.set_walk_bonus(v)
		value_label.text = _percent(v))
	row.add_child(label)
	row.add_child(slider)
	row.add_child(value_label)
	_show_limit(row, mod_main)
	return row


# Shows the current limit. Signals are blocked so a lower limit doesn't overwrite the
# stored bonus: walking is capped at sprint anyway, and raising sprint again restores it.
static func _show_limit(row: HBoxContainer, mod_main) -> void:
	var max_bonus: float = mod_main.max_walk_bonus()
	var label := row.get_child(0) as RichTextLabel
	var slider := row.get_child(1) as HSlider
	var value_label := row.get_child(2) as RichTextLabel
	label.text = "Walk Speed (up to sprint) +" + _percent(max_bonus)
	slider.set_block_signals(true)
	slider.max_value = max_bonus
	slider.value = minf(mod_main.walk_bonus, max_bonus)
	slider.set_block_signals(false)
	value_label.text = _percent(slider.value)


static func _sprint_adjuster(panel: PassiveBonuses) -> PassiveBonusAdjustable:
	for child in panel.get_children():
		if child is PassiveBonusAdjustable and child.property_name == SPRINT_PASSIVE and not child.is_queued_for_deletion():
			return child
	return null


static func _percent(value: float) -> String:
	return str(roundi(value * 100)) + "%"
