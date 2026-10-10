extends Object

# Same as axe.hooks.gd for the battleaxe whirl.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-axe_glare_toggle_mod/mod_main.gd"


func _physics_process(chain: ModLoaderHookChain, delta: float) -> void:
	chain.execute_next([delta])
	if load(MOD_MAIN_PATH).hide_glare():
		(chain.reference_object as BattleaxeWhirl).gpu_particles.emitting = false
