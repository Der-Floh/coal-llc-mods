extends Object

const LOG_NAME := "der_floh-tick_upgrade_mod:ProfessionHook"

# Appended to every profession's unlocked_passives so that the
# NanobotZ-AutoPassiveChooser settings UI can display and prioritise
# our custom tick-speed passives.
const MOD_PASSIVES: Array = ["poison_tick_speed", "fire_tick_speed"]


func _profession_effect(chain: ModLoaderHookChain, _data: Dictionary) -> Dictionary:
	var result: Dictionary = chain.execute_next([_data])

	if result.has("unlocked_passives"):
		for key in MOD_PASSIVES:
			if key not in result["unlocked_passives"]:
				result["unlocked_passives"].append(key)

	return result
