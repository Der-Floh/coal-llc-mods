extends Object

# Adds the new passives to the offer pool while they are worth offering (the player
# owns an item they apply to, or a vacuum, and they are below their cap). The same
# list feeds NanobotZ-AutoPassiveChooser's priority settings.
#
# Also: assassins field Strong Elementalists, whose water globs make wet tiles take
# double damage, and already unlock poison_damage, but vanilla never offers them
# wet_damage. It is added to the assassin's pool.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-extra_passives_mod/mod_main.gd"


func _profession_effect(chain: ModLoaderHookChain, _data: Dictionary) -> Dictionary:
	var result: Dictionary = chain.execute_next([_data])
	if not result.has("unlocked_passives"):
		return result
	var mod_main = load(MOD_MAIN_PATH)
	if not mod_main.get_enabled():
		return result
	var pool: Array = result["unlocked_passives"]
	for key in mod_main.PASSIVES:
		if mod_main.offerable(key) and key not in pool:
			pool.append(key)
	var script: Script = (chain.reference_object as Object).get_script()
	if script and script.resource_path.ends_with("/assassin.gd") and "wet_damage" not in pool:
		pool.append("wet_damage")
	return result
