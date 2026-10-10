class_name IngenitusMoveSpeedSliderMod
extends Node

const MOD_ID := "ingenitus-move_speed_slider_mod"
const MOD_DIR := "ingenitus-move_speed_slider_mod"
const LOG_NAME := "ingenitus-move_speed_slider_mod:Main"
const PLAYER_SCRIPT_PATH := "res://scripts/StateMachine/Player2/player_2.gd"

# Extra walk speed as a fraction of the base walk speed. Kept in the mod config
# rather than the run save: it is a control preference like auto-sprint, and
# the game's save files stay untouched, so removing the mod leaves nothing behind.
static var walk_bonus: float = 0.0
# Cached config switch; the player hook runs every physics frame.
static var _enabled: bool = true

var mod_dir_path: String
var extensions_dir_path: String


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	extensions_dir_path = mod_dir_path.path_join("extensions")
	_enabled = get_enabled()
	walk_bonus = maxf(0.0, float(get_config().data.get("walk_speed_bonus", 0.0)))
	install_hooks()


func install_hooks() -> void:
	# Script Hooks: walking uses the adjusted speed; the Tab panel gets the slider.
	ModLoaderMod.install_script_hooks(
		"res://scripts/StateMachine/Player2/player_2.gd",
		extensions_dir_path.path_join("scripts/StateMachine/Player2/player_2.hooks.gd")
	)
	ModLoaderMod.install_script_hooks(
		"res://scenes/Interfaces/Management/passive_bonuses.gd",
		extensions_dir_path.path_join("scenes/Interfaces/Management/passive_bonuses.hooks.gd")
	)


func _ready() -> void:
	ModLoaderLog.info("Ready! enabled=%s walk_bonus=%s" % [str(_enabled), str(walk_bonus)], LOG_NAME)


# --- Speeds ---

# Walk speed the player moves at: the base walk speed plus the bonus, capped at the
# speed sprinting would give right now (including the sprint slider).
static func walk_speed_for(walk_speed: float, sprint_speed: float) -> float:
	var sprint_now: float = sprint_speed * (1.0 + Gvars.passives.adjusted_player_sprint_speed)
	return minf(walk_speed * (1.0 + walk_bonus), sprint_now)


# Largest useful bonus: the one that makes walking as fast as fully earned sprint.
# Base sprint (150) is already faster than base walk (100), and the speed quest
# reward doubles sprint only, so the range is open even with no sprint passive.
static func max_walk_bonus() -> float:
	# Loaded at call time: naming the Player class here would compile player_2.gd
	# together with mod_main, before the game's autoloads exist.
	var player_script = load(PLAYER_SCRIPT_PATH)
	var sprint: float = player_script.BASE_SPRINT_SPEED
	if Gvars.bonus_equipment_manager.passive_player_speed_increase:
		sprint *= 2.0
	return sprint * (1.0 + Gvars.passives.player_sprint_speed) / player_script.BASE_WALK_SPEED - 1.0


static func set_walk_bonus(value: float) -> void:
	walk_bonus = maxf(0.0, value)
	var cfg := get_config()
	cfg.data["walk_speed_bonus"] = walk_bonus
	ModLoaderConfig.update_config(cfg)


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
	_enabled = value
