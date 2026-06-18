class_name DerFlohGameLimitsMod
extends Node

const MOD_ID := "der_floh-game_limits_mod"
const MOD_DIR := "der_floh-game_limits_mod"
const LOG_NAME := "der_floh-game_limits_mod:Main"

const DEFAULT_MAX_MORTARS: int = 1000
const DEFAULT_CHUNK_LOAD_RADIUS: int = 3
const DEFAULT_CHUNKS_PER_FRAME: int = 1
const DEFAULT_MAX_ELECTRIC_CHAIN: int = 500
const DEFAULT_MAX_ELECTRIC_VISUALS: int = 200

var mod_dir_path := ""
var extensions_dir_path := ""


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	extensions_dir_path = mod_dir_path.path_join("extensions")
	install_hooks()


func _ready() -> void:
	_debug = get_debug_logging()
	ModLoaderLog.info(
		"Game Limits Mod ready. Max mortars: %d, Chunk radius: %d, Chunks/frame: %d, Max electric chain: %d, Max electric visuals: %d, debug_logging: %s" % [
			get_max_mortars(), get_chunk_load_radius(), get_chunks_per_frame(), get_max_electric_chain(), get_max_electric_visuals(), str(_debug)
		],
		LOG_NAME
	)


func install_hooks() -> void:
	ModLoaderMod.install_script_hooks(
		"res://scenes/Interfaces/Menus/settings_2.gd",
		extensions_dir_path.path_join("scenes/Interfaces/Menus/settings_2.hooks.gd")
	)
	ModLoaderMod.install_script_hooks(
		"res://scenes/ManagersInScene/mortar_manager.gd",
		extensions_dir_path.path_join("scenes/ManagersInScene/mortar_manager.hooks.gd")
	)
	ModLoaderMod.install_script_hooks(
		"res://scenes/tilemaps/tile_map_manager.gd",
		extensions_dir_path.path_join("scenes/tilemaps/tile_map_manager.hooks.gd")
	)
	ModLoaderMod.install_script_hooks(
		"res://scripts/PauseMenu.gd",
		extensions_dir_path.path_join("scripts/PauseMenu.hooks.gd")
	)
	ModLoaderMod.install_script_hooks(
		"res://scenes/equipment/electric_shock.gd",
		extensions_dir_path.path_join("scenes/equipment/electric_shock.hooks.gd")
	)


# Returns the mutable user config, creating it from schema defaults on first call.
# The "default" config is read-only in GML; "user" is our mutable config label.
static func get_config() -> ModConfig:
	const LABEL := "user"
	if ModLoaderConfig.has_config(MOD_ID, LABEL):
		return ModLoaderConfig.get_config(MOD_ID, LABEL)
	return ModLoaderConfig.create_config(MOD_ID, LABEL, ModLoaderConfig.get_default_config(MOD_ID).data)


static func get_max_mortars() -> int:
	return int(get_config().data.get("max_mortars", DEFAULT_MAX_MORTARS))


static func set_max_mortars(value: int) -> void:
	var cfg := get_config()
	cfg.data["max_mortars"] = int(value)
	ModLoaderConfig.update_config(cfg)


static func get_chunk_load_radius() -> int:
	return int(get_config().data.get("chunk_load_radius", DEFAULT_CHUNK_LOAD_RADIUS))


static func set_chunk_load_radius(value: int) -> void:
	var cfg := get_config()
	cfg.data["chunk_load_radius"] = int(value)
	ModLoaderConfig.update_config(cfg)


static func get_chunks_per_frame() -> int:
	return int(get_config().data.get("chunks_per_frame", DEFAULT_CHUNKS_PER_FRAME))


static func set_chunks_per_frame(value: int) -> void:
	var cfg := get_config()
	cfg.data["chunks_per_frame"] = int(value)
	ModLoaderConfig.update_config(cfg)


static func get_max_electric_chain() -> int:
	return int(get_config().data.get("max_electric_chain", DEFAULT_MAX_ELECTRIC_CHAIN))


static func set_max_electric_chain(value: int) -> void:
	var cfg := get_config()
	cfg.data["max_electric_chain"] = int(value)
	ModLoaderConfig.update_config(cfg)


static func get_max_electric_visuals() -> int:
	return int(get_config().data.get("max_electric_visuals", DEFAULT_MAX_ELECTRIC_VISUALS))


static func set_max_electric_visuals(value: int) -> void:
	var cfg := get_config()
	cfg.data["max_electric_visuals"] = int(value)
	ModLoaderConfig.update_config(cfg)


static var _debug: bool = false


static func get_debug_logging() -> bool:
	return bool(get_config().data.get("debug_logging", false))


static func set_debug_logging(value: bool) -> void:
	var cfg := get_config()
	cfg.data["debug_logging"] = value
	ModLoaderConfig.update_config(cfg)


static func get_enabled() -> bool:
	return bool(get_config().data.get("enabled", true))


static func set_enabled(value: bool) -> void:
	var cfg := get_config()
	cfg.data["enabled"] = value
	ModLoaderConfig.update_config(cfg)
