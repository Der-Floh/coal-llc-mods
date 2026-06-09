class_name DerFlohPassiveDropMod
extends Node

const MOD_ID  := "der_floh-passive_drop_mod"
const MOD_DIR := "der_floh-passive_drop_mod"
const LOG_NAME := "der_floh-passive_drop_mod:Main"

const DEFAULT_GOLDEN_WEAPONS_ENABLED   := 1
const DEFAULT_CHEST_GENERATION_ENABLED := 0
const DEFAULT_AUTO_COLLECT_PASSIVES    := 0
const DEFAULT_CHANCE_NON_ORE           := 0

# Per-ore default drop chances (%). Rarer ores have higher defaults.
const CHANCE_DEFAULTS: Dictionary = {
	"coal":         1,
	"copper":       2,
	"iron":         4,
	"silver":       6,
	"gold":         8,
	"amethyst":     10,
	"sapphire":     20,
	"emerald":      30,
	"ruby":         40,
	"diamond":      50,
	"pink_diamond": 60,
	"spinel":       70,
	"uranium":      80,
	"moonstone":    90,
	"onyx":         100,
	"non_ore":      0,
}

# Each entry: [config_key, display_name].
# Used by the settings tab to build per-ore rows.
# Config value is stored as "chance_<key>" (integer 0-100).
const ORE_ENTRIES: Array = [
	["coal",         "Coal"],
	["copper",       "Copper"],
	["iron",         "Iron"],
	["silver",       "Silver"],
	["gold",         "Gold"],
	["amethyst",     "Amethyst"],
	["sapphire",     "Sapphire"],
	["emerald",      "Emerald"],
	["ruby",         "Ruby"],
	["diamond",      "Diamond"],
	["pink_diamond", "Pink Diamond"],
	["spinel",       "Spinel"],
	["uranium",      "Uranium"],
	["moonstone",    "Moonstone"],
	["onyx",         "Onyx"],
]

var mod_dir_path: String
var extensions_dir_path: String


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	extensions_dir_path = mod_dir_path.path_join("extensions")
	install_hooks()


func _ready() -> void:
	_debug = get_debug_logging()
	ModLoaderLog.info("Ready! debug_logging=%s" % str(_debug), LOG_NAME)


func install_hooks() -> void:
	# destroy_tile + generate_chests both live in tile_map_chunk.gd
	ModLoaderMod.install_script_hooks(
		"res://scenes/tilemaps/tile_map_chunk.gd",
		extensions_dir_path.path_join("scenes/tilemaps/tile_map_chunk.hooks.gd")
	)
	ModLoaderMod.install_script_hooks(
		"res://scripts/Chest.gd",
		extensions_dir_path.path_join("scripts/Chest.hooks.gd")
	)
	ModLoaderMod.install_script_hooks(
		"res://scenes/Interfaces/Menus/settings_2.gd",
		extensions_dir_path.path_join("scenes/Interfaces/Menus/settings_2.hooks.gd")
	)


# --- Config ---

static func get_config() -> ModConfig:
	const LABEL := "user"
	if ModLoaderConfig.has_config(MOD_ID, LABEL):
		return ModLoaderConfig.get_config(MOD_ID, LABEL)
	return ModLoaderConfig.create_config(MOD_ID, LABEL, ModLoaderConfig.get_default_config(MOD_ID).data)


# --- Per-ore drop chance (key e.g. "coal", "pink_diamond", "non_ore") ---

static func get_chance_for_key(key: String) -> int:
	var fallback: int = CHANCE_DEFAULTS.get(key, 0)
	return int(get_config().data.get("chance_" + key, fallback))


static func set_chance_for_key(key: String, value: int) -> void:
	var cfg := get_config()
	cfg.data["chance_" + key] = int(value)
	ModLoaderConfig.update_config(cfg)


# --- Chest / behaviour toggles ---

static func get_golden_weapons_enabled() -> bool:
	return int(get_config().data.get("golden_weapons_enabled", DEFAULT_GOLDEN_WEAPONS_ENABLED)) != 0


static func set_golden_weapons_enabled(value: bool) -> void:
	var cfg := get_config()
	cfg.data["golden_weapons_enabled"] = int(value)
	ModLoaderConfig.update_config(cfg)


static func get_chest_generation_enabled() -> bool:
	return int(get_config().data.get("chest_generation_enabled", DEFAULT_CHEST_GENERATION_ENABLED)) != 0


static func set_chest_generation_enabled(value: bool) -> void:
	var cfg := get_config()
	cfg.data["chest_generation_enabled"] = int(value)
	ModLoaderConfig.update_config(cfg)


static func get_auto_collect_passives() -> bool:
	return int(get_config().data.get("auto_collect_passives", DEFAULT_AUTO_COLLECT_PASSIVES)) != 0


static func set_auto_collect_passives(value: bool) -> void:
	var cfg := get_config()
	cfg.data["auto_collect_passives"] = int(value)
	ModLoaderConfig.update_config(cfg)


static var _debug: bool = false


static func get_debug_logging() -> bool:
	return bool(get_config().data.get("debug_logging", false))


static func set_debug_logging(value: bool) -> void:
	var cfg := get_config()
	cfg.data["debug_logging"] = value
	ModLoaderConfig.update_config(cfg)
