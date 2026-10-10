extends Object

# axe_spin_speed for the battleaxe whirl, same as axe.hooks.gd.
# The whirl spins up (and down) faster. Vanilla moves rotation_speed
# toward its target by delta * ACCELERATION (x DECELERATION_MULTIPLIER when
# stopping); after vanilla's step the same move is continued by the extra share,
# which equals one step at ACCELERATION * (1 + axe_spin_speed). Top speed and
# damage per hit are unchanged.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-extra_passives_mod/mod_main.gd"


func _physics_process(chain: ModLoaderHookChain, delta: float) -> void:
	chain.execute_next([delta])
	var extra: float = load(MOD_MAIN_PATH).level("axe_spin_speed")
	if extra <= 0.0:
		return
	var whirl = chain.reference_object
	if whirl.on:
		whirl.rotation_speed = move_toward(whirl.rotation_speed, whirl.MAX_ROTATION_SPEED, delta * whirl.ACCELERATION * extra)
	else:
		whirl.rotation_speed = move_toward(whirl.rotation_speed, 0, delta * whirl.ACCELERATION * whirl.DECELERATION_MULTIPLIER * extra)
