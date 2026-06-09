class_name DerFlohOreValueMod
extends Node

const MOD_ID  := "der_floh-ore_value_mod"
const MOD_DIR := "der_floh-ore_value_mod"
const LOG_NAME := "der_floh-ore_value_mod:Main"

# Maps vanilla itemID strings to config schema keys.
const ITEM_ID_TO_KEY := {
	"Coal":        "coal",
	"CopperOre":   "copper",
	"IronOre":     "iron",
	"SilverOre":   "silver",
	"GoldOre":     "gold",
	"Amethyst":    "amethyst",
	"Sapphire":    "sapphire",
	"Emerald":     "emerald",
	"Ruby":        "ruby",
	"Diamond":     "diamond",
	"PinkDiamond": "pink_diamond",
	"spinel":      "spinel",
	"uranium":     "uranium",
	"moonstone":   "moonstone",
	"onyx":        "onyx",
}

var mod_dir_path: String
var extensions_dir_path: String


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	extensions_dir_path = mod_dir_path.path_join("extensions")
	install_hooks()


func _ready() -> void:
	_debug = get_debug_logging()
	# Re-apply price multipliers at the start of each new mining day so that
	# settings changed during the management screen take effect immediately.
	Bus.StartDay.connect(_on_start_day)
	ModLoaderLog.info("Ready! debug_logging=%s" % str(_debug), LOG_NAME)


func _on_start_day() -> void:
	Gvars.reset_resources()
	ModLoaderLog.debug("Ore sell prices refreshed for new day.", LOG_NAME)


func install_hooks() -> void:
	ModLoaderMod.install_script_extension(
		extensions_dir_path.path_join("scripts/Gvars.gd")
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


static func get_multiplier(item_id: String) -> float:
	var key: String = ITEM_ID_TO_KEY.get(item_id, "")
	if key.is_empty():
		return 1.0
	return float(get_config().data.get(key, 1.0))


static func set_multiplier(item_id: String, value: float) -> void:
	var key: String = ITEM_ID_TO_KEY.get(item_id, "")
	if key.is_empty():
		return
	var cfg := get_config()
	cfg.data[key] = value
	ModLoaderConfig.update_config(cfg)


static var _debug: bool = false


static func get_debug_logging() -> bool:
	return bool(get_config().data.get("debug_logging", false))


static func set_debug_logging(value: bool) -> void:
	var cfg := get_config()
	cfg.data["debug_logging"] = value
	ModLoaderConfig.update_config(cfg)
