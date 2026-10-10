extends Object

const LOG_NAME := "ingenitus-custom_seed_mod:SettingsHook"


func _ready(chain: ModLoaderHookChain) -> void:
	chain.execute_next()

	var settings := chain.reference_object as SettingsMenu
	var tab_node := preload("res://mods-unpacked/ingenitus-custom_seed_mod/scenes/mod_custom_seed_tab.tscn").instantiate()

	settings.tab_container.add_child(tab_node)
	ModLoaderLog.info("World Seed tab added to settings menu.", LOG_NAME)
