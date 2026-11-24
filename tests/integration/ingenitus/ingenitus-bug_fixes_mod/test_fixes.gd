extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Fixes that need no mine: the settings tab, late-day quotas, save restore, negative cash,
# x0 employee boxes, chest card multipliers and AOE miner reach. Each is checked with the fix
# off too, which shows the vanilla bug.

const MOD_ID := "ingenitus-bug_fixes_mod"
const FIX_LABELS := [
	"Coal quota no longer overflows on late days",
	"Restore a missing or corrupt save from its backup",
	"Resuming with Esc can no longer leave the game paused",
	"Buying can no longer leave cash below zero",
	"Merged or collected loot can no longer be counted twice",
	"Loot cap holds during one-frame bursts (nukes, earthquakes)",
	"Explosions reach their bottom and right edges",
	"Hide employee boxes that show x0",
	"Chest upgrade cards keep their own chest's multiplier",
	"AOE miners also hit the tiles right next to their target",
]
const LATE_DAY := 62
const VANILLA_OVERFLOW := -1.1068046444225731e29
const FIXED_QUOTA := 2.2136092888451462e29
const INTERN := "res://resources/Employees/EmployeeLevels/intern.tres"
const CHEST_SCENE := "res://scenes/Chest.tscn"
const MINER_SCENES := ["res://scenes/AutoMiners/multi_miner.tscn", "res://scenes/AutoMiners/multi_miner_flying.tscn"]
const MINER_TARGET := Vector2i(10, 10)
const TEST_SAVE := "user://bug_fixes_test.save"
const TEST_BACKUP := "user://bug_fixes_test_backup.save"


func before_each() -> void:
	await in_management()


func test_settings_tab_lists_every_fix() -> void:
	var rows := settings_rows(await open_settings(), "Bug Fixes")
	expect_eq(rows.get("Mod Enabled"), true, "Mod Enabled")
	for label in FIX_LABELS:
		expect_eq(rows.get(label), true, label)


func test_quota_keeps_growing_after_day_61() -> void:
	var bug_fixes = mod(MOD_ID)
	var modes = tree.root.get_node("Gconsts").Mode
	use_value(gvars, "mode", modes.NORMAL)
	expect_eq(gvars.increaseQuota(0.0, LATE_DAY), VANILLA_OVERFLOW, "vanilla's day-62 quota overflows")
	expect_eq(bug_fixes.fixed_quota(LATE_DAY), FIXED_QUOTA, "fixed day-62 quota")
	expect_eq(bug_fixes.fixed_quota(61), gvars.increaseQuota(0.0, 61), "days up to 61 are unchanged")
	gvars.mode = modes.TOUGH_START
	expect_eq(bug_fixes.fixed_quota(LATE_DAY), FIXED_QUOTA / 2.0, "slow mode gets half")
	gvars.mode = modes.PEACEFUL
	expect(is_nan(bug_fixes.fixed_quota(LATE_DAY)), "peaceful mode, which has no quota, is left alone")


func test_missing_or_corrupt_save_is_restored_from_backup() -> void:
	var content := JSON.stringify({"marker": 42})
	_write(TEST_BACKUP, content + "\n")
	_write(TEST_SAVE, "{corrupt")
	on_cleanup(func() -> void:
		DirAccess.remove_absolute(TEST_SAVE)
		DirAccess.remove_absolute(TEST_BACKUP))
	mod(MOD_ID).restore_if_needed(TEST_SAVE, TEST_BACKUP)
	expect_eq(FileAccess.get_file_as_string(TEST_SAVE).strip_edges(), content, "a corrupt save is restored")
	DirAccess.remove_absolute(TEST_SAVE)
	mod(MOD_ID).restore_if_needed(TEST_SAVE, TEST_BACKUP)
	expect_eq(FileAccess.get_file_as_string(TEST_SAVE).strip_edges(), content, "a missing save is restored")


# Buying the most you can afford deducts (cash / cost) * cost, which rounding can put just above the cash held.
func test_cash_never_ends_below_zero_after_buying() -> void:
	var intern = load(INTERN)
	var cash := _cash_that_rounds_below_zero(intern.upgrade_cost)
	if not expect(cash > 0.0, "a cash value whose purchase rounds below zero exists"):
		return
	var employees = gvars.employee_manager
	use_value(gvars, "CashCount", cash)
	employees.purchase_employee_level(intern, 1.0e30)
	expect_eq(gvars.CashCount, 0.0, "cash after buying all you can afford with %s" % cash)
	_use_fix("fix_negative_cash", false)
	gvars.CashCount = cash
	employees.purchase_employee_level(intern, 1.0e30)
	expect(gvars.CashCount < 0.0, "vanilla leaves %s, below zero" % gvars.CashCount)


static func _cash_that_rounds_below_zero(cost: float) -> float:
	for step in range(1, 10000):
		var cash := step * 0.1
		if cash - (cash / cost) * cost < 0.0:
			return cash
	return 0.0


func test_zero_employee_boxes_are_hidden() -> void:
	expect_eq(_zero_boxes(), [["x0", false, false], ["x0", false, false]], "[label, label shown, sell shown] for counts that print as x0")
	_use_fix("fix_zero_employee_boxes", false)
	expect_eq(_zero_boxes(), [["x0", true, true], ["x0", true, true]], "vanilla shows them")


func test_chest_cards_keep_their_own_multiplier() -> void:
	expect_eq(_card_multipliers(), [1.0, 4.0, false], "[level-1 card, level-4 card, same effect object]")
	_use_fix("fix_card_multiplier", false)
	expect_eq(_card_multipliers(), [4.0, 4.0, true], "vanilla shares one card effect between chests")


func test_aoe_miners_reach_their_neighbours() -> void:
	expect_eq(_miner_reach(), [[8, 24], [8, 24]], "[radius 1, radius 2] tiles for ground and flying miners")
	_use_fix("fix_aoe_gap", false)
	expect_eq(_miner_reach(), [[4, 16], [4, 16]], "vanilla reach")


func _use_fix(key: String, on: bool) -> void:
	var bug_fixes = mod(MOD_ID)
	var previous: bool = bug_fixes.get_config().data.get(key, true)
	bug_fixes.set_fix(key, on)
	on_cleanup(func() -> void: bug_fixes.set_fix(key, previous))


func _zero_boxes() -> Array:
	var screen = game.current_node.management_instance
	var employees = gvars.employee_manager
	var names = EmployeeLevel.EmployeeLevelNames
	employees.employees[names.INTERN] = 0.1 + 0.2 - 0.3
	employees.employees[names.WEAK_BOMBER] = 1.0e-9
	screen.organisation_chart.refresh_all_icons()
	var boxes := []
	for icon in screen.organisation_chart.all_employee_icons:
		if icon.employee_level.level_name in [names.INTERN, names.WEAK_BOMBER]:
			boxes.append([icon.count_label.text, icon.count_label.visible, icon.sell_employee.visible])
	employees.reset()
	screen.organisation_chart.refresh_all_icons()
	return boxes


func _card_multipliers() -> Array:
	var scene = load(CHEST_SCENE)
	var low = scene.instantiate()
	var high = scene.instantiate()
	low.loot_level = 1
	high.loot_level = 4
	for chest in [low, high]:
		for i in 100:
			chest.roll_loot()
			if chest.loot.itemType == "passive_upgrade":
				break
	var cards := [low.loot.itemPickupEffect, high.loot.itemPickupEffect]
	var result := [cards[0].multiplier, cards[1].multiplier, cards[0] == cards[1]]
	low.free()
	high.free()
	return result


func _miner_reach() -> Array:
	var reach := []
	for path in MINER_SCENES:
		var miner = load(path).instantiate()
		reach.append([miner.get_radius(MINER_TARGET, 1).size(), miner.get_radius(MINER_TARGET, 2).size()])
		miner.free()
	return reach


static func _write(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
	file.close()
