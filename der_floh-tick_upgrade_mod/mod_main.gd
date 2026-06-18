class_name DerFlohTickUpgradeMod
extends Node

const MOD_ID  := "der_floh-tick_upgrade_mod"
const MOD_DIR := "der_floh-tick_upgrade_mod"
const LOG_NAME := "der_floh-tick_upgrade_mod:Main"

var mod_dir_path: String
var extensions_dir_path: String


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	extensions_dir_path = mod_dir_path.path_join("extensions")
	install_hooks()


func _ready() -> void:
	_debug = get_debug_logging()
	ModLoaderLog.info("Ready! poison_tick_speed=%.2f fire_tick_speed=%.2f always_distant=%s preserve_duration=%s debug_logging=%s" % [
		poison_tick_speed, fire_tick_speed,
		str(get_always_tick_distant()),
		str(get_preserve_duration()),
		str(_debug),
	], LOG_NAME)


func install_hooks() -> void:
	# Script Hooks: inject tick-speed passives into the passive chooser UI.
	ModLoaderMod.install_script_hooks(
		"res://scenes/Interfaces/in_game/choose_passive.gd",
		extensions_dir_path.path_join("scenes/Interfaces/in_game/choose_passive.hooks.gd")
	)

	# Script Hooks: call extra poison/burn loops per frame when tick speed > 1.
	ModLoaderMod.install_script_hooks(
		"res://scenes/tilemaps/tile_map_chunk.gd",
		extensions_dir_path.path_join("scenes/tilemaps/tile_map_chunk.hooks.gd")
	)

	# Script Hooks: process DISABLED (out-of-range) chunks that still have effects.
	ModLoaderMod.install_script_hooks(
		"res://scenes/tilemaps/tile_map_manager.gd",
		extensions_dir_path.path_join("scenes/tilemaps/tile_map_manager.hooks.gd")
	)

	# Script Hooks: add settings tab to the settings menu.
	ModLoaderMod.install_script_hooks(
		"res://scenes/Interfaces/Menus/settings_2.gd",
		extensions_dir_path.path_join("scenes/Interfaces/Menus/settings_2.hooks.gd")
	)

	# Script Hooks: append our custom passives to the passive bonuses panel (Tab key).
	ModLoaderMod.install_script_hooks(
		"res://scenes/Interfaces/Management/passive_bonuses.gd",
		extensions_dir_path.path_join("scenes/Interfaces/Management/passive_bonuses.hooks.gd")
	)

	# Script Hooks: inject our passives into every profession's unlocked_passives so
	# NanobotZ-AutoPassiveChooser can display and prioritise them in its settings UI.
	# One shared hook file is registered for each profession script.
	var profession_hook := extensions_dir_path.path_join(
		"resources/professions/scripts/profession.hooks.gd"
	)
	var profession_scripts: Array[String] = [
		"resources/professions/scripts/profession.gd",
		"resources/professions/scripts/assassin.gd",
		"resources/professions/scripts/barbarian.gd",
		"resources/professions/scripts/demolitionist.gd",
		"resources/professions/scripts/destructor.gd",
		"resources/professions/scripts/firestarter.gd",
		"resources/professions/scripts/generalist.gd",
		"resources/professions/scripts/generalist_plus.gd",
		"resources/professions/scripts/gunslinger.gd",
		"resources/professions/scripts/internship.gd",
		"resources/professions/scripts/lone_ranger.gd",
		"resources/professions/scripts/lumberjack.gd",
		"resources/professions/scripts/martial_artist.gd",
		"resources/professions/scripts/maverick.gd",
		"resources/professions/scripts/mule.gd",
		"resources/professions/scripts/orbist.gd",
		"resources/professions/scripts/shaman.gd",
		"resources/professions/scripts/shotgunner.gd",
		"resources/professions/scripts/tanker.gd",
		"resources/professions/scripts/ultimate_destructor.gd",
		"resources/professions/scripts/waterbender.gd",
		"resources/professions/scripts/wizard.gd",
	]
	for script_path in profession_scripts:
		ModLoaderMod.install_script_hooks("res://" + script_path, profession_hook)


# --- Runtime tick-speed state ---
# Stored on this mod (not as a Gvars extension) so hook files can reach it via
# load(mod_main) without the type checker rejecting an extension-added property.
# Multipliers (1.0 = vanilla); both persist for the process, matching the old
# Gvars-extension behaviour (reset_game never touched them).

static var poison_tick_speed: float = 1.0
static var fire_tick_speed: float = 1.0


static func get_poison_tick_speed() -> float:
	return poison_tick_speed


static func get_fire_tick_speed() -> float:
	return fire_tick_speed


static func add_poison_tick_speed(amount: float) -> void:
	poison_tick_speed += amount


static func add_fire_tick_speed(amount: float) -> void:
	fire_tick_speed += amount


# --- Config ---

static func get_config() -> ModConfig:
	const LABEL := "user"
	if ModLoaderConfig.has_config(MOD_ID, LABEL):
		return ModLoaderConfig.get_config(MOD_ID, LABEL)
	return ModLoaderConfig.create_config(MOD_ID, LABEL, ModLoaderConfig.get_default_config(MOD_ID).data)


static func get_always_tick_distant() -> bool:
	return bool(get_config().data.get("always_tick_distant", true))


static func set_always_tick_distant(value: bool) -> void:
	var cfg := get_config()
	cfg.data["always_tick_distant"] = value
	ModLoaderConfig.update_config(cfg)


static func get_preserve_duration() -> bool:
	return bool(get_config().data.get("preserve_duration", true))


static func set_preserve_duration(value: bool) -> void:
	var cfg := get_config()
	cfg.data["preserve_duration"] = value
	ModLoaderConfig.update_config(cfg)


static var _debug: bool = false


static func get_debug_logging() -> bool:
	return bool(get_config().data.get("debug_logging", false))


static func set_debug_logging(value: bool) -> void:
	var cfg := get_config()
	cfg.data["debug_logging"] = value
	ModLoaderConfig.update_config(cfg)
