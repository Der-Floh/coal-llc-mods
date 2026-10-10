extends Object

# Vanilla _physics_process picks `speed = walk_speed` whenever the player is not
# sprinting. walk_speed is raised to the adjusted value for the duration of the
# call and put back afterwards, so nothing else sees a changed base speed (the
# walking animation still scales against the base, as it does for sprinting).

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-move_speed_slider_mod/mod_main.gd"


func _physics_process(chain: ModLoaderHookChain, delta: float) -> void:
	var mod_main = load(MOD_MAIN_PATH)
	if not mod_main._enabled or mod_main.walk_bonus <= 0.0:
		chain.execute_next([delta])
		return
	var player := chain.reference_object as Player
	var base: float = player.walk_speed
	player.walk_speed = mod_main.walk_speed_for(base, player.sprint_speed)
	chain.execute_next([delta])
	player.walk_speed = base
