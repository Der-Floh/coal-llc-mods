extends Object

const LOG_NAME := "der_floh-ore_value_mod:SettingsHook"


func _ready(chain: ModLoaderHookChain) -> void:
	chain.execute_next()

	var settings := chain.reference_object as SettingsMenu
	var tab_node := preload("res://mods-unpacked/der_floh-ore_value_mod/scenes/mod_ore_value_tab.tscn").instantiate()

	settings.tab_container.add_child(tab_node)
	ModLoaderLog.info("Ore Value tab added to settings menu.", LOG_NAME)
