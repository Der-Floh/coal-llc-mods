extends Object

const LOG_NAME := "ingenitus-axe_glare_toggle_mod:SettingsHook"


func _ready(chain: ModLoaderHookChain) -> void:
	chain.execute_next()

	var settings := chain.reference_object as SettingsMenu
	var tab_node := preload("res://mods-unpacked/ingenitus-axe_glare_toggle_mod/scenes/mod_axe_glare_tab.tscn").instantiate()

	settings.tab_container.add_child(tab_node)
	ModLoaderLog.info("Axe Glare tab added to settings menu.", LOG_NAME)
