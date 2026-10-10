extends Object

# drill_speed: the drill's "mining" animation (which triggers each dig) plays faster.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-extra_passives_mod/mod_main.gd"


func _ready(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	var speed: float = load(MOD_MAIN_PATH).level("drill_speed")
	if speed > 0.0:
		chain.reference_object.animation_player.speed_scale = 1.0 + speed
