class_name DerFlohPerfMod
extends Node

const MOD_ID := "der_floh-performance_mod"
const MOD_DIR := "der_floh-performance_mod"
const LOG_NAME := "der_floh-performance_mod:Main"
const GAME_LIMITS_ID := "der_floh-game_limits_mod"
const GAME_LIMITS_MAIN_PATH := "res://mods-unpacked/der_floh-game_limits_mod/mod_main.gd"

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

func _ready() -> void:
	_debug = get_debug_logging()
	_game_limits = _find_game_limits()
	ModLoaderLog.info("Ready! debug_logging=%s, game_limits_mod found=%s" % [str(_debug), str(_game_limits != null)], LOG_NAME)


# --- Game Limits ---

static var _game_limits = null


static func get_enabled_game_limits():
	if _game_limits == null or not _game_limits.get_enabled():
		return null
	return _game_limits


static func _find_game_limits():
	if ModLoaderMod.is_mod_active(GAME_LIMITS_ID) and ResourceLoader.exists(GAME_LIMITS_MAIN_PATH):
		return load(GAME_LIMITS_MAIN_PATH)
	return null


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
