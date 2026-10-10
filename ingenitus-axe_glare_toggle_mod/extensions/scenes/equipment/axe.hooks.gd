extends Object

# Vanilla _physics_process turns %GPUParticles on at full spin and off otherwise,
# every physics frame. Running it first and then forcing emitting off keeps the
# spin, movement and damage untouched and only removes the glare.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-axe_glare_toggle_mod/mod_main.gd"


func _physics_process(chain: ModLoaderHookChain, delta: float) -> void:
	chain.execute_next([delta])
	if load(MOD_MAIN_PATH).hide_glare():
		(chain.reference_object as AxeWhirl).gpu_particles.emitting = false
