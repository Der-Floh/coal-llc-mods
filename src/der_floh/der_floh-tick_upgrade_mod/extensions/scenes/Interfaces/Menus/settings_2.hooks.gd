extends Object

const LOG_NAME := "der_floh-tick_upgrade_mod:SettingsHook"


func _ready(chain: ModLoaderHookChain) -> void:
	chain.execute_next()

	var settings := chain.reference_object as SettingsMenu
	var tab_node := preload("res://mods-unpacked/der_floh-tick_upgrade_mod/scenes/mod_tick_upgrade_tab.tscn").instantiate()

	settings.tab_container.add_child(tab_node)
	ModLoaderLog.info("Tick Upgrades tab added to settings menu.", LOG_NAME)
