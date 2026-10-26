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

const ITEM_PATHS := {
	"Coal":        "res://resources/Items/Coal.tres",
	"CopperOre":   "res://resources/Items/Minerals/Copper.tres",
	"IronOre":     "res://resources/Items/Minerals/Iron.tres",
	"SilverOre":   "res://resources/Items/Minerals/Silver.tres",
	"GoldOre":     "res://resources/Items/Minerals/Gold.tres",
	"Amethyst":    "res://resources/Items/Gems/Amethyst.tres",
	"Sapphire":    "res://resources/Items/Gems/Sapphire.tres",
	"Emerald":     "res://resources/Items/Gems/Emerald.tres",
	"Ruby":        "res://resources/Items/Gems/Ruby.tres",
	"Diamond":     "res://resources/Items/Gems/Diamond.tres",
	"PinkDiamond": "res://resources/Items/Gems/PinkDiamond.tres",
	"spinel":      "res://resources/Items/Gems/Spinel.tres",
	"uranium":     "res://resources/Items/Gems/Uranium.tres",
	"moonstone":   "res://resources/Items/Gems/Moonstone.tres",
	"onyx":        "res://resources/Items/Gems/Onyx.tres",
}

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
	ModLoaderMod.install_script_extension(
		extensions_dir_path.path_join("scripts/Gvars.gd")
	)
	ModLoaderMod.install_script_hooks(
		"res://scenes/Interfaces/Menus/settings_2.gd",
		extensions_dir_path.path_join("scenes/Interfaces/Menus/settings_2.hooks.gd")
	)


# --- Prices ---

# Keeps the priced items alive: the game holds no reference to some ores, and a freed item reloads at its vanilla price.
static var _items := {}
static var _vanilla_items := {}


static func apply_prices() -> void:
	var enabled := get_enabled()
	for item_id in ITEM_PATHS:
		var item = load(ITEM_PATHS[item_id])
		var vanilla_item = _vanilla_item(item_id)
		if item == null or vanilla_item == null:
			continue
		_items[item_id] = item
		var base_price: float = _coal_value() if item_id == "Coal" else vanilla_item.itemSellPrice
		var multiplier: float = get_multiplier(item_id) if enabled else 1.0
		item.itemSellPrice = base_price * multiplier
		if _debug and multiplier != 1.0:
			ModLoaderLog.info("%s sell price x%s = %.0f" % [item_id, str(multiplier), item.itemSellPrice], LOG_NAME)


static func _vanilla_item(item_id: String):
	if not _vanilla_items.has(item_id):
		_vanilla_items[item_id] = ResourceLoader.load(ITEM_PATHS[item_id], "", ResourceLoader.CacheMode.CACHE_MODE_IGNORE)
	return _vanilla_items[item_id]


static func _coal_value() -> float:
	var hard_modifier = Gvars.hard_modifier
	if hard_modifier == null:
		return 1.0
	return float(hard_modifier._hard_modifier_effect({"coal_value": 1})["coal_value"])


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


static func get_enabled() -> bool:
	return bool(get_config().data.get("enabled", true))


static func set_enabled(value: bool) -> void:
	var cfg := get_config()
	cfg.data["enabled"] = value
	ModLoaderConfig.update_config(cfg)
