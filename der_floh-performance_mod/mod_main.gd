class_name DerFlohPerfMod
extends Node

const MOD_ID := "der_floh-performance_mod"
const MOD_DIR := "der_floh-performance_mod"
const LOG_NAME := "der_floh-performance_mod:Main"

var mod_dir_path: String
var extensions_dir_path: String


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	extensions_dir_path = mod_dir_path.path_join("extensions")
	install_hooks()


func install_hooks() -> void:
	ModLoaderMod.install_script_hooks(
		"res://scenes/tilemaps/tile_map_manager.gd",
		extensions_dir_path.path_join("scenes/tilemaps/tile_map_manager.hooks.gd")
	)
	ModLoaderMod.install_script_hooks(
		"res://scenes/tilemaps/tile_map_chunk.gd",
		extensions_dir_path.path_join("scenes/tilemaps/tile_map_chunk.hooks.gd")
	)
	ModLoaderMod.install_script_hooks(
		"res://scenes/equipment/electric_shock.gd",
		extensions_dir_path.path_join("scenes/equipment/electric_shock.hooks.gd")
	)
	ModLoaderMod.install_script_hooks(
		"res://scenes/Interfaces/Menus/settings_2.gd",
		extensions_dir_path.path_join("scenes/Interfaces/Menus/settings_2.hooks.gd")
	)


func _ready() -> void:
	_debug = get_debug_logging()
	ModLoaderLog.info("Ready! debug_logging=%s" % str(_debug), LOG_NAME)


# --- Config ---

static func get_config() -> ModConfig:
	const LABEL := "user"
	if ModLoaderConfig.has_config(MOD_ID, LABEL):
		return ModLoaderConfig.get_config(MOD_ID, LABEL)
	return ModLoaderConfig.create_config(MOD_ID, LABEL, ModLoaderConfig.get_default_config(MOD_ID).data)


static var _debug: bool = false


static func get_debug_logging() -> bool:
	return bool(get_config().data.get("debug_logging", false))


static func set_debug_logging(value: bool) -> void:
	var cfg := get_config()
	cfg.data["debug_logging"] = value
	ModLoaderConfig.update_config(cfg)
