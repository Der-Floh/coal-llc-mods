class_name IngenitusCustomSeedMod
extends Node

const MOD_ID := "ingenitus-custom_seed_mod"
const MOD_DIR := "ingenitus-custom_seed_mod"
const LOG_NAME := "ingenitus-custom_seed_mod:Main"

var mod_dir_path: String
var extensions_dir_path: String


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	extensions_dir_path = mod_dir_path.path_join("extensions")
	install_hooks()


func install_hooks() -> void:
	# Script Hooks: seed each chunk's generation from (seed, day, chunk position).
	ModLoaderMod.install_script_hooks(
		"res://scenes/tilemaps/tile_map_manager.gd",
		extensions_dir_path.path_join("scenes/tilemaps/tile_map_manager.hooks.gd")
	)

	# Script Hooks: add settings tab to the settings menu.
	ModLoaderMod.install_script_hooks(
		"res://scenes/Interfaces/Menus/settings_2.gd",
		extensions_dir_path.path_join("scenes/Interfaces/Menus/settings_2.hooks.gd")
	)


func _ready() -> void:
	ModLoaderLog.info("Ready! seed=%d same_every_day=%s enabled=%s debug_logging=%s" % [
		get_seed(), str(get_same_every_day()), str(get_enabled()), str(get_debug_logging()),
	], LOG_NAME)


# --- Seeds ---
# The settings are snapshotted when a level starts, so changing them mid-day never
# leaves a seam between chunks generated before and after the change.

static var _level_seed: int = 0
static var _level_day: int = 0
static var _level_started: bool = false


# Called when a mining level is initialised.
static func begin_level() -> void:
	_level_started = true
	_level_seed = get_seed() if get_enabled() else 0
	_level_day = 0 if get_same_every_day() else int(Gvars.dayCount)


# Seed for one chunk, or -1 when no seed is active (vanilla generation).
static func chunk_seed(chunk_id: Vector2i) -> int:
	if not _level_started:
		begin_level()
	if _level_seed == 0:
		return -1
	return _mix([_level_seed, _level_day, chunk_id.x, chunk_id.y])


# Terrain noise seed for the current level.
static func noise_seed() -> int:
	return _mix([_level_seed, _level_day])


static func _mix(parts: Array) -> int:
	return hash(parts) & 0x7FFFFFFF


# --- Config ---

static func get_config() -> ModConfig:
	const LABEL := "user"
	if ModLoaderConfig.has_config(MOD_ID, LABEL):
		return ModLoaderConfig.get_config(MOD_ID, LABEL)
	return ModLoaderConfig.create_config(MOD_ID, LABEL, ModLoaderConfig.get_default_config(MOD_ID).data)


static func get_seed() -> int:
	return int(get_config().data.get("seed", 0))


static func set_seed(value: int) -> void:
	var cfg := get_config()
	cfg.data["seed"] = value
	ModLoaderConfig.update_config(cfg)


static func get_same_every_day() -> bool:
	return bool(get_config().data.get("same_every_day", false))


static func set_same_every_day(value: bool) -> void:
	var cfg := get_config()
	cfg.data["same_every_day"] = value
	ModLoaderConfig.update_config(cfg)


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
