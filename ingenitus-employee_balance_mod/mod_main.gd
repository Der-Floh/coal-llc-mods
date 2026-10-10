class_name IngenitusEmployeeBalanceMod
extends Node

const MOD_ID := "ingenitus-employee_balance_mod"
const MOD_DIR := "ingenitus-employee_balance_mod"
const LOG_NAME := "ingenitus-employee_balance_mod:Main"

# In vanilla every bomber and elementalist (buffer) tier has mining_speed 0.5, the
# intern's value, while miners (0.8 -> 1.6) and barbarians (0.5 -> 1.0) speed up
# with tier. mining_speed is the swing cadence (multi_miner animation.speed_scale).
# Their abilities (bombs, elemental globs) are unchanged.
const MINING_SPEED := {
	"res://resources/Employees/EmployeeLevels/weak_bomber.tres": 0.6,
	"res://resources/Employees/EmployeeLevels/medium_bomber.tres": 0.7,
	"res://resources/Employees/EmployeeLevels/strong_bomber.tres": 0.8,
	"res://resources/Employees/EmployeeLevels/fast_bomber.tres": 0.9,
	"res://resources/Employees/EmployeeLevels/artillery.tres": 1.0,
	"res://resources/Employees/EmployeeLevels/weak_buffer.tres": 0.6,
	"res://resources/Employees/EmployeeLevels/medium_buffer.tres": 0.8,
	"res://resources/Employees/EmployeeLevels/strong_buffer.tres": 1.0,
}

# The levels are shared, cached resources: every miner the game spawns reads its
# EmployeeLevel from the same instance. Holding them keeps the cache (and the new
# values) alive; the vanilla values are kept to restore them when disabled.
static var _levels: Dictionary = {}  # path -> EmployeeLevel
static var _vanilla: Dictionary = {}  # path -> float


func _ready() -> void:
	apply()
	ModLoaderLog.info("Ready! enabled=%s" % str(get_enabled()), LOG_NAME)


static func apply() -> void:
	var enabled := get_enabled()
	for path in MINING_SPEED:
		if not _levels.has(path):
			var level: EmployeeLevel = load(path)
			_levels[path] = level
			_vanilla[path] = level.mining_speed
		_levels[path].mining_speed = MINING_SPEED[path] if enabled else _vanilla[path]


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
	apply()
