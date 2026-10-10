extends Object

const LOG_NAME := "ingenitus-bug_fixes_mod:SettingsHook"


func _ready(chain: ModLoaderHookChain) -> void:
	chain.execute_next()

	var settings := chain.reference_object as SettingsMenu
	var tab_node := preload("res://mods-unpacked/ingenitus-bug_fixes_mod/scenes/mod_bug_fixes_tab.tscn").instantiate()

	settings.tab_container.add_child(tab_node)
	ModLoaderLog.info("Bug Fixes tab added to settings menu.", LOG_NAME)
