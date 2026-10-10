extends Object

const LOG_NAME := "der_floh-game_limits_mod:SettingsHook"


func _ready(chain: ModLoaderHookChain) -> void:
	chain.execute_next()

	var settings := chain.reference_object as SettingsMenu
	var tab_node := preload("res://mods-unpacked/der_floh-game_limits_mod/scenes/mod_limits_tab.tscn").instantiate()

	settings.tab_container.add_child(tab_node)
	# Link the vanilla Gameplay-tab employee slider so both controls adjust the
	# same setting and display the same value without duplicating the backing logic.
	tab_node.link_vanilla_employee_slider(settings.max_employee_draws)

	ModLoaderLog.info("Game Limits tab added to settings menu.", LOG_NAME)
