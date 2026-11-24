extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Resuming with Esc can no longer leave the game paused with no menu. The race is reproduced by
# resuming right after process_frame, before the menu's _process re-pauses the tree.

const MOD_ID := "ingenitus-bug_fixes_mod"
const GAME_LIMITS_ID := "der_floh-game_limits_mod"
const PAUSE_MENU := "res://scenes/PauseMenu.tscn"


func before_each() -> void:
	await in_mine()


func test_resume_never_leaves_the_game_paused() -> void:
	_switch_game_limits(false)
	expect_eq(await _race_resume(), {"paused": false, "menus": 0}, "after resuming in the race window")


func test_the_race_freezes_without_the_fix() -> void:
	_switch_game_limits(false)
	var bug_fixes = mod(MOD_ID)
	bug_fixes.set_fix("fix_pause_resume", false)
	on_cleanup(func() -> void: bug_fixes.set_fix("fix_pause_resume", true))
	expect_eq(await _race_resume(), {"paused": true, "menus": 0}, "vanilla gets stuck paused with no menu")


func test_running_both_pause_fixes_is_harmless() -> void:
	if not require_mods([GAME_LIMITS_ID]):
		return
	expect_eq(await _race_resume(), {"paused": false, "menus": 0}, "with Game Limits' fix on too")


func _switch_game_limits(enabled: bool) -> void:
	if has_mod(GAME_LIMITS_ID):
		use_setting(GAME_LIMITS_ID, "enabled", enabled)


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
