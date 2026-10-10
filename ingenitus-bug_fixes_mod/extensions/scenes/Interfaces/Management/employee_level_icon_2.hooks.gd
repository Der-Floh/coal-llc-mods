extends Object

# fix_zero_employee_boxes. Employee counts are floats. Promoting employees out of a
# level leaves float dust there (e.g. 1e-9): not exactly 0, so refresh() keeps the
# count label and sell button visible and, where the level cannot be bought, shows
# the employee as owned. The label rounds the dust to "x0". After vanilla runs,
# counts that would display as zero are treated as zero.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-bug_fixes_mod/mod_main.gd"


func refresh(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	var icon := chain.reference_object as EmployeeLevelIcon2
	if icon.count == 0.0 or icon.count >= 0.5 or not load(MOD_MAIN_PATH).is_on("fix_zero_employee_boxes"):
		return
	icon.count_label.visible = false
	icon.sell_employee.visible = false
	icon.sell_employee.focus_mode = Control.FOCUS_NONE
	if not icon.purchaseable and icon.demo_locked_panel.visible == false:
		icon.employee_node.modulate = Color(0, 0, 0, 1)
		icon.tool.use_parent_material = true
