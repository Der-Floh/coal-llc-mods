extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Resuming with Esc could leave the game paused with no menu: the menu's _process re-pauses the
# tree in the same frame the resume ran. The race is reproduced by resuming right after
# process_frame, before nodes process.

const MOD_ID := "der_floh-game_limits_mod"
const BUG_FIXES_ID := "ingenitus-bug_fixes_mod"
const PAUSE_MENU := "res://scenes/PauseMenu.tscn"


func before_each() -> void:
	await in_mine()


func test_resume_never_leaves_the_game_paused() -> void:
	_switch_bug_fixes_pause_fix(false)
	expect_eq(await _race_resume(), {"paused": false, "menus": 0}, "after resuming in the race window")


func test_the_race_freezes_without_any_fix() -> void:
	_switch_bug_fixes_pause_fix(false)
	use_setting(MOD_ID, "enabled", false)
	expect_eq(await _race_resume(), {"paused": true, "menus": 0}, "vanilla gets stuck paused with no menu, so the test reproduces the bug")


func test_running_both_pause_fixes_is_harmless() -> void:
	if not require_mods([BUG_FIXES_ID]):
		return
	_switch_bug_fixes_pause_fix(true)
	expect_eq(await _race_resume(), {"paused": false, "menus": 0}, "with both fixes on")


func _switch_bug_fixes_pause_fix(on: bool) -> void:
	if not has_mod(BUG_FIXES_ID):
		return
	var bug_fixes = mod(BUG_FIXES_ID)
	var previous: bool = bug_fixes.get_config().data.get("fix_pause_resume", true)
	bug_fixes.set_fix("fix_pause_resume", on)
	on_cleanup(func() -> void: bug_fixes.set_fix("fix_pause_resume", previous))


func _race_resume() -> Dictionary:
	gui().game_in_focus = false
	gui().OpenPauseMenu()
	await frames(3)
	var menu = _pause_menus().front()
	await tree.process_frame
	menu.on_pressed_resume()
	await frames(4)
	var result := {"paused": tree.paused, "menus": _pause_menus().size()}
	tree.paused = false
	gui().game_in_focus = true
	return result


func _pause_menus() -> Array:
	return gui().get_children().filter(func(node) -> bool: return node.scene_file_path == PAUSE_MENU and not node.is_queued_for_deletion())
