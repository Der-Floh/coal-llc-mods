extends Object

const LOG_NAME := "der_floh-passive_drop_mod:ChestHook"

const PASSIVE_RES_PATH := "res://resources/Items/power_ups/PassiveUpgrade.tres"


func roll_loot(chain: ModLoaderHookChain) -> void:
	chain.execute_next()

	var mod_main := load("res://mods-unpacked/der_floh-passive_drop_mod/mod_main.gd")
	if mod_main.get_golden_weapons_enabled():
		return  # weapon scrolls allowed — nothing to change

	var chest := chain.reference_object as Chest

	# Gems (itemType "gem") and passives are unaffected; only weapon scrolls (type "scroll")
	if chest.loot == null or chest.loot.itemType != "scroll":
		return

	# Replace the weapon scroll with a passive upgrade using vanilla's multiplier formula
	var passive_upgrade: Item = load(PASSIVE_RES_PATH).duplicate(true)
	if chest.loot_level <= 4:
		passive_upgrade.itemPickupEffect.multiplier = float(chest.loot_level)
	else:
		passive_upgrade.itemPickupEffect.multiplier = float(chest.loot_level ** 2)

	chest.loot = passive_upgrade
	chest.loot_count = 1
