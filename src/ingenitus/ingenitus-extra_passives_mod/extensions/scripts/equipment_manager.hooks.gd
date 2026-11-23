extends Object

# vacuum_range lengthens the hose of the vacuum generate_vacuum_cleaner just built
# (the vacuum reads vacuum_length every physics frame for its rope and snap-back);
# vacuum_power widens the suction end that grabs loot (the vacuum has no pulling
# force, so suction = grab area). Picks later in the day re-apply both through
# mod_main.refresh_vacuums.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-extra_passives_mod/mod_main.gd"


func generate_vacuum_cleaner(chain: ModLoaderHookChain) -> void:
	var manager := chain.reference_object as Node
	var before := manager.get_child_count()
	chain.execute_next()
	var mod_main = load(MOD_MAIN_PATH)
	for i in range(before, manager.get_child_count()):
		var vacuum := manager.get_child(i)
		if "vacuum_length" in vacuum:
			vacuum.add_to_group(mod_main.VACUUM_GROUP)
			mod_main.apply_vacuum_bonus(vacuum)
