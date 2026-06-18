extends Object

const LOG_NAME := "der_floh-tick_upgrade_mod:PassiveBonusHook"
# Access mod_main via load() — a mod's class_name is not in GDScript's global
# registry, so referencing DerFlohTickUpgradeMod from this script would not compile.
const MOD_MAIN_PATH := "res://mods-unpacked/der_floh-tick_upgrade_mod/mod_main.gd"


func refresh(chain: ModLoaderHookChain) -> void:
	chain.execute_next()

	var self_obj := chain.reference_object as PassiveBonuses

	# Append labels for our custom passives if the player has taken any upgrades.
	# delta = amount above the 1.0 baseline — e.g. 1.2 → "+20%"
	# We call the vanilla add_label() helper so the format matches the other rows.
	var mod_main := load(MOD_MAIN_PATH)
	var poison_delta: float = mod_main.get_poison_tick_speed() - 1.0
	if poison_delta > 0.0:
		self_obj.add_label("poison_tick_speed", poison_delta)

	var fire_delta: float = mod_main.get_fire_tick_speed() - 1.0
	if fire_delta > 0.0:
		self_obj.add_label("fire_tick_speed", fire_delta)
