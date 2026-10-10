class_name IngenitusNumberFormatMod
extends Node

const MOD_ID := "ingenitus-number_format_mod"
const MOD_DIR := "ingenitus-number_format_mod"
const LOG_NAME := "ingenitus-number_format_mod:Main"

var mod_dir_path: String
var extensions_dir_path: String


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	extensions_dir_path = mod_dir_path.path_join("extensions")
	install_hooks()


func install_hooks() -> void:
	# Script Hooks: tidy the scientific-notation fallback of the number formatter.
	ModLoaderMod.install_script_hooks(
		"res://scripts/Gconsts.gd",
		extensions_dir_path.path_join("scripts/Gconsts.hooks.gd")
	)


func _ready() -> void:
	ModLoaderLog.info("Ready! enabled=%s" % str(get_enabled()), LOG_NAME)


# "1.23e11" for a value vanilla would print with String.num_scientific.
static func short_scientific(value: float) -> String:
	var exponent := int(floor(log(absf(value)) / log(10.0)))
	var mantissa := value / pow(10.0, exponent)
	if absf(mantissa) >= 9.995:  # would round to "10.00"
		exponent += 1
		mantissa /= 10.0
	return "%.2fe%d" % [mantissa, exponent]


# --- Config ---

static func get_config() -> ModConfig:
	const LABEL := "user"
	if ModLoaderConfig.has_config(MOD_ID, LABEL):
		return ModLoaderConfig.get_config(MOD_ID, LABEL)
	return ModLoaderConfig.create_config(MOD_ID, LABEL, ModLoaderConfig.get_default_config(MOD_ID).data)


static func get_enabled() -> bool:
	return bool(get_config().data.get("enabled", true))


static func set_enabled(value: bool) -> void:
	var cfg := get_config()
	cfg.data["enabled"] = value
	ModLoaderConfig.update_config(cfg)
