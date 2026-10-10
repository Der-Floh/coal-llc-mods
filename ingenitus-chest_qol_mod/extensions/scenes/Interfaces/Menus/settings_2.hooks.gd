extends Object

const LOG_NAME := "ingenitus-chest_qol_mod:SettingsHook"


func _ready(chain: ModLoaderHookChain) -> void:
	chain.execute_next()

	var settings := chain.reference_object as SettingsMenu
	var tab_node := preload("res://mods-unpacked/ingenitus-chest_qol_mod/scenes/mod_chest_qol_tab.tscn").instantiate()

	settings.tab_container.add_child(tab_node)
	ModLoaderLog.info("Chests tab added to settings menu.", LOG_NAME)
