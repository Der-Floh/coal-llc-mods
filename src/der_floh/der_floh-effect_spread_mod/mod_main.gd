class_name DerFlohEffectSpreadMod
extends Node

const MOD_ID := "der_floh-effect_spread_mod"
const MOD_DIR := "der_floh-effect_spread_mod"
const LOG_NAME := "der_floh-effect_spread_mod:Main"

const DEFAULT_SPREAD_RADIUS: int = 3
const DEFAULT_INHERIT_TICKS: bool = true
const DEFAULT_FRESH_TICKS: int = 10

var mod_dir_path: String
var extensions_dir_path: String


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	extensions_dir_path = mod_dir_path.path_join("extensions")
	install_hooks()


func _ready() -> void:
	_debug = get_debug_logging()
	ModLoaderLog.info(
		"Effect Spread Mod ready. radius=%d, inherit_ticks=%s, fresh_ticks=%d, debug_logging=%s" % [
			get_spread_radius(), str(get_inherit_ticks()), get_fresh_ticks(), str(_debug)
		],
		LOG_NAME
	)


func install_hooks() -> void:
	ModLoaderMod.install_script_hooks(
		"res://scenes/tilemaps/tile_map_chunk.gd",
		extensions_dir_path.path_join("scenes/tilemaps/tile_map_chunk.hooks.gd")
	)
	ModLoaderMod.install_script_hooks(
		"res://scenes/Interfaces/Menus/settings_2.gd",
		extensions_dir_path.path_join("scenes/Interfaces/Menus/settings_2.hooks.gd")
	)


# Returns the mutable user config, creating it from schema defaults on first call.
# The "default" config is read-only in GML; "user" is our mutable config label.
static func get_config() -> ModConfig:
	const LABEL := "user"
	if ModLoaderConfig.has_config(MOD_ID, LABEL):
		return ModLoaderConfig.get_config(MOD_ID, LABEL)
	return ModLoaderConfig.create_config(MOD_ID, LABEL, ModLoaderConfig.get_default_config(MOD_ID).data)


static func get_spread_radius() -> int:
	return int(get_config().data.get("spread_radius", DEFAULT_SPREAD_RADIUS))


static func set_spread_radius(value: float) -> void:
	var cfg := get_config()
	cfg.data["spread_radius"] = int(value)
	ModLoaderConfig.update_config(cfg)


static func get_inherit_ticks() -> bool:
	return bool(get_config().data.get("inherit_ticks", DEFAULT_INHERIT_TICKS))


static func set_inherit_ticks(value: bool) -> void:
	var cfg := get_config()
	cfg.data["inherit_ticks"] = value
	ModLoaderConfig.update_config(cfg)


static func get_fresh_ticks() -> int:
	return int(get_config().data.get("fresh_ticks", DEFAULT_FRESH_TICKS))


static func set_fresh_ticks(value: float) -> void:
	var cfg := get_config()
	cfg.data["fresh_ticks"] = int(value)
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
