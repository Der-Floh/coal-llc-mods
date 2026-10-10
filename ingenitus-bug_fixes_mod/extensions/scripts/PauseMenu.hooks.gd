extends Object

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-bug_fixes_mod/mod_main.gd"


# fix_pause_resume: the pause menu re-pauses the tree in its own _process every
# frame, and resuming only queue_free()s it. When resume comes from the Esc
# shortcut (handled before _process in a frame), that same frame's _process pauses
# the tree again and then the menu is freed: the game is stuck paused with no menu.
# Stopping the menu's processing before vanilla resumes closes that window.
func on_pressed_resume(chain: ModLoaderHookChain) -> void:
	if load(MOD_MAIN_PATH).is_on("fix_pause_resume"):
		(chain.reference_object as Node).set_process(false)
	chain.execute_next()
