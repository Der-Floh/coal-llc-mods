class_name IngenitusChestQolMod
extends Node

const MOD_ID := "ingenitus-chest_qol_mod"
const MOD_DIR := "ingenitus-chest_qol_mod"
const LOG_NAME := "ingenitus-chest_qol_mod:Main"

# Config key -> settings-tab label.
const OPTIONS := {
	"auto_open": "Open chests when you touch them",
	"auto_grab": "Loot straight to inventory on touch (needs One-Click Looting)",
	"ring_reach": "Reach chests from their protective tiles once one is mined",
	"skip_weaker_scrolls": "Replace power-up scrolls for weapons weaker than yours",
}

var mod_dir_path: String
var extensions_dir_path: String


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	extensions_dir_path = mod_dir_path.path_join("extensions")
	install_hooks()


func install_hooks() -> void:
	# Script Hooks: touch to open/loot, protective-ring reach, weaker-scroll swap.
	ModLoaderMod.install_script_hooks(
		"res://scripts/Chest.gd",
		extensions_dir_path.path_join("scripts/Chest.hooks.gd")
	)

	# Script Hooks: add settings tab to the settings menu.
	ModLoaderMod.install_script_hooks(
		"res://scenes/Interfaces/Menus/settings_2.gd",
		extensions_dir_path.path_join("scenes/Interfaces/Menus/settings_2.hooks.gd")
	)


func _ready() -> void:
	var data: Dictionary = get_config().data
	var on := []
	for key in OPTIONS:
		if bool(data.get(key, true)):
			on.append(key)
	ModLoaderLog.info("Ready! enabled=%s options_on=%s" % [str(get_enabled()), str(on)], LOG_NAME)


# True when the mod is enabled and the given option is switched on.
static func is_on(key: String) -> bool:
	var data: Dictionary = get_config().data
	return bool(data.get("enabled", true)) and bool(data.get(key, true))


# --- Config ---

static func get_config() -> ModConfig:
	const LABEL := "user"
	if ModLoaderConfig.has_config(MOD_ID, LABEL):
		return ModLoaderConfig.get_config(MOD_ID, LABEL)
	return ModLoaderConfig.create_config(MOD_ID, LABEL, ModLoaderConfig.get_default_config(MOD_ID).data)


static func set_option(key: String, value: bool) -> void:
	var cfg := get_config()
	cfg.data[key] = value
	ModLoaderConfig.update_config(cfg)


static func get_enabled() -> bool:
	return bool(get_config().data.get("enabled", true))


static func set_enabled(value: bool) -> void:
	var cfg := get_config()
	cfg.data["enabled"] = value
	ModLoaderConfig.update_config(cfg)
