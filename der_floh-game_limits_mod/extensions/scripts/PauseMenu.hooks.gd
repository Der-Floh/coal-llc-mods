extends Object

const LOG_NAME := "der_floh-game_limits_mod:PauseMenuHook"


func on_pressed_resume(chain: ModLoaderHookChain) -> void:
	if not load("res://mods-unpacked/der_floh-game_limits_mod/mod_main.gd").get_enabled():
		chain.execute_next()
		return
	# PauseMenu._process() forces get_tree().paused = true every frame.
	# When on_pressed_resume is triggered by _shortcut_input (Escape key),
	# the input phase runs before _process in the same frame. This means
	# vanilla would set paused=false and queue_free() here, then _process
	# would set paused=true again in the same frame, leaving the game frozen
	# after PauseMenu is freed.
	# Disabling _process before vanilla executes prevents that re-pause.
	(chain.reference_object as Node).set_process(false)
	chain.execute_next()
