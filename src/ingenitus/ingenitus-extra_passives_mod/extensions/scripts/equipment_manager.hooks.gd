extends Object

# vacuum_range lengthens the hose of the vacuum generate_vacuum_cleaner just built
# (the vacuum reads vacuum_length every physics frame for its rope and snap-back);
# vacuum_power widens the suction end that grabs loot (the vacuum has no pulling
# force, so suction = grab area).

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-extra_passives_mod/mod_main.gd"


func generate_vacuum_cleaner(chain: ModLoaderHookChain) -> void:
	var manager := chain.reference_object as Node
	var before := manager.get_child_count()
	chain.execute_next()
	if manager.get_child_count() == before:
		return  # no vacuum owned
	var vacuum: Node = manager.get_child(manager.get_child_count() - 1)
	if not "vacuum_length" in vacuum:
		return
	var mod_main = load(MOD_MAIN_PATH)
	vacuum.vacuum_length = int(vacuum.vacuum_length * (1.0 + mod_main.level("vacuum_range")))
	var power: float = mod_main.level("vacuum_power")
	if power > 0.0:
		vacuum.suck_end.scale = Vector2.ONE * (1.0 + power)
