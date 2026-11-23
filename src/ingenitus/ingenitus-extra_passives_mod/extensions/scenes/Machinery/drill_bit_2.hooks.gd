extends Object

# drill_mining_speed: the drill's "mining" animation (which triggers each dig) plays faster.
# Drills join a group, so a later pick speeds up the ones already placed too.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-extra_passives_mod/mod_main.gd"


func _ready(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	var mod_main = load(MOD_MAIN_PATH)
	var drill: Node = chain.reference_object
	drill.add_to_group(mod_main.DRILL_GROUP)
	mod_main.apply_drill_speed(drill)
