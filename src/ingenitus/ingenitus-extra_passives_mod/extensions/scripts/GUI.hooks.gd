extends Object

# Wraps building a level-up card, so profession.hooks.gd can tell an offer from other
# readers of the passive pool (NanobotZ-AutoPassiveChooser's priority list).

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-extra_passives_mod/mod_main.gd"


func on_choose_passive(chain: ModLoaderHookChain, multiplier: float) -> void:
	var mod_main = load(MOD_MAIN_PATH)
	mod_main.building_offer = true
	chain.execute_next([multiplier])
	mod_main.building_offer = false
