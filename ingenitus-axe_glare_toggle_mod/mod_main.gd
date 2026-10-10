class_name IngenitusAxeGlareToggleMod
extends Node

const MOD_ID := "ingenitus-axe_glare_toggle_mod"
const MOD_DIR := "ingenitus-axe_glare_toggle_mod"
const LOG_NAME := "ingenitus-axe_glare_toggle_mod:Main"

var mod_dir_path: String
var extensions_dir_path: String


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	extensions_dir_path = mod_dir_path.path_join("extensions")
	install_hooks()


func install_hooks() -> void:
	# Script Hooks: switch the whirl's glare particles off after vanilla sets them.
	ModLoaderMod.install_script_hooks(
		"res://scenes/equipment/axe.gd",
		extensions_dir_path.path_join("scenes/equipment/axe.hooks.gd")
	)
	ModLoaderMod.install_script_hooks(
		"res://scenes/equipment/battleaxe.gd",
		extensions_dir_path.path_join("scenes/equipment/battleaxe.hooks.gd")
	)

	# Script Hooks: add settings tab to the settings menu.
	ModLoaderMod.install_script_hooks(
		"res://scenes/Interfaces/Menus/settings_2.gd",
		extensions_dir_path.path_join("scenes/Interfaces/Menus/settings_2.hooks.gd")
	)


func _ready() -> void:
	ModLoaderLog.info("Ready! show_glare=%s enabled=%s" % [str(get_show_glare()), str(get_enabled())], LOG_NAME)


# True when the glare should be suppressed.
static func hide_glare() -> bool:
	return get_enabled() and not get_show_glare()


# --- Config ---

static func get_config() -> ModConfig:
	const LABEL := "user"
	if ModLoaderConfig.has_config(MOD_ID, LABEL):
		return ModLoaderConfig.get_config(MOD_ID, LABEL)
	return ModLoaderConfig.create_config(MOD_ID, LABEL, ModLoaderConfig.get_default_config(MOD_ID).data)


static func get_show_glare() -> bool:
	return bool(get_config().data.get("show_glare", false))


static func set_show_glare(value: bool) -> void:
	var cfg := get_config()
	cfg.data["show_glare"] = value
	ModLoaderConfig.update_config(cfg)


static func get_enabled() -> bool:
	return bool(get_config().data.get("enabled", true))


static func set_enabled(value: bool) -> void:
	var cfg := get_config()
	cfg.data["enabled"] = value
	ModLoaderConfig.update_config(cfg)
