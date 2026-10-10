extends Object

# fix_card_multiplier. roll_loot makes each chest's passive-upgrade card with
# PASSIVE_UPGRADE.duplicate(), a shallow copy, so every card shares one pickup
# effect and sets its multiplier on that shared object. The value is only read when
# the card is picked up, so it is whatever the most recently rolled chest set: a
# level-1 card becomes x4 once a level-4 chest rolls, and a level-4 card drops to x1
# after a level-1 chest. Each card now gets its own effect with its own chest's
# multiplier (vanilla's formula).

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-bug_fixes_mod/mod_main.gd"


func roll_loot(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	if not load(MOD_MAIN_PATH).is_on("fix_card_multiplier"):
		return
	var chest := chain.reference_object as Chest
	if chest.loot == null or chest.loot.itemType != "passive_upgrade":
		return
	var effect = chest.loot.itemPickupEffect.duplicate()
	effect.multiplier = float(chest.loot_level) if chest.loot_level <= 4 else float(chest.loot_level ** 2)
	chest.loot.itemPickupEffect = effect
