class_name IngenitusBugFixesMod
extends Node

const MOD_ID := "ingenitus-bug_fixes_mod"
const MOD_DIR := "ingenitus-bug_fixes_mod"
const LOG_NAME := "ingenitus-bug_fixes_mod:Main"

# Config key -> settings-tab label. Every fix can be switched off on its own.
const FIXES := {
	"fix_quota_overflow": "Coal quota no longer overflows on late days",
	"fix_save_restore": "Restore a missing or corrupt save from its backup",
	"fix_pause_resume": "Resuming with Esc can no longer leave the game paused",
	"fix_negative_cash": "Buying can no longer leave cash below zero",
	"fix_loot_duplication": "Merged or collected loot can no longer be counted twice",
	"fix_loot_burst": "Loot cap holds during one-frame bursts (nukes, earthquakes)",
	"fix_blast_edges": "Explosions reach their bottom and right edges",
	"fix_zero_employee_boxes": "Hide employee boxes that show x0",
	"fix_card_multiplier": "Chest upgrade cards keep their own chest's multiplier",
	"fix_aoe_gap": "AOE miners also hit the tiles right next to their target",
}

var mod_dir_path: String
var extensions_dir_path: String


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	extensions_dir_path = mod_dir_path.path_join("extensions")
	install_hooks()
	# Runs before the game's Gvars autoload reads the saves at startup.
	if is_on("fix_save_restore"):
		for pair in SAVE_FILES:
			restore_if_needed(pair[0], pair[1])


func install_hooks() -> void:
	var hooks := {
		"res://scenes/Stages/management_screen.gd": "scenes/Stages/management_screen.hooks.gd",
		"res://scripts/PauseMenu.gd": "scripts/PauseMenu.hooks.gd",
		"res://scripts/ItemPickup2.gd": "scripts/ItemPickup2.hooks.gd",
		"res://scripts/loot_drops.gd": "scripts/loot_drops.hooks.gd",
		"res://scenes/tilemaps/tile_map_manager.gd": "scenes/tilemaps/tile_map_manager.hooks.gd",
		"res://scenes/Interfaces/Management/employee_level_icon_2.gd": "scenes/Interfaces/Management/employee_level_icon_2.hooks.gd",
		"res://resources/Employees/Scripts/employee_manager.gd": "resources/Employees/Scripts/employee_manager.hooks.gd",
		"res://scripts/Chest.gd": "scripts/Chest.hooks.gd",
		"res://scenes/AutoMiners/multi_miner.gd": "scenes/AutoMiners/multi_miner.hooks.gd",
		"res://scenes/AutoMiners/multi_miner_flying.gd": "scenes/AutoMiners/multi_miner_flying.hooks.gd",
		# Settings tab.
		"res://scenes/Interfaces/Menus/settings_2.gd": "scenes/Interfaces/Menus/settings_2.hooks.gd",
	}
	for vanilla_path in hooks:
		ModLoaderMod.install_script_hooks(vanilla_path, extensions_dir_path.path_join(hooks[vanilla_path]))


func _ready() -> void:
	var off := []
	for key in FIXES:
		if not bool(get_config().data.get(key, true)):
			off.append(key)
	ModLoaderLog.info("Ready! enabled=%s fixes_off=%s" % [str(get_enabled()), str(off)], LOG_NAME)
	# Connected once every autoload is ready, so it runs after Gvars.on_StartDay.
	(func() -> void: Bus.StartDay.connect(_on_start_day)).call_deferred()


# --- fix_quota_overflow ---
# Past the end of COAL_QUOTAS, Gvars.increaseQuota multiplies the last quota by
# `4 ** (day - len)`, an integer power. From day 62 (32 days past the 30-day table)
# it overflows and the quota goes negative (about -1.1e29), so every day counts as
# met. The same growth is computed in floating point instead; earlier days are
# identical. Applied after vanilla sets the day's quota, and to the "Upcoming Coal
# Quota" line on the management screen (management_screen.hooks.gd).

# The quota for a day, or NAN when vanilla's own value is correct (table days,
# peaceful mode, or the fix switched off).
static func fixed_quota(day: int) -> float:
	if not is_on("fix_quota_overflow"):
		return NAN
	var table: Array = Gvars.COAL_QUOTAS
	var past_table: int = day - table.size()
	if past_table < 0 or Gvars.mode == Gconsts.Mode.PEACEFUL:
		return NAN
	var grown: float = table[table.size() - 1] * pow(4.0, past_table)
	return grown * 0.5 if Gvars.mode == Gconsts.Mode.TOUGH_START else grown


func _on_start_day() -> void:
	var quota := fixed_quota(Gvars.dayCount)
	if not is_nan(quota):
		Gvars.coalQuota = quota
		Bus.UpdateUI.emit()


# --- fix_save_restore ---
# Every save file has a backup copy, but vanilla only reads the primary. A missing
# primary loads defaults, a corrupt one loads nothing, and the next save then
# overwrites the good backup too, so progress is lost for good. If the primary
# cannot be parsed and the backup can, the backup is put back before the game
# loads (mod _init runs before the Gvars autoload). Paths match Gconsts.
const SAVE_FILES := [
	["user://v04_saveglobals.save", "user://v04_saveglobals_backup.save"],
	["user://v04_records.save", "user://v04_records_backup.save"],
	["user://v04_modifiers.save", "user://v04_modifiers_backup.save"],
]


static func restore_if_needed(primary: String, backup: String) -> void:
	if _read_json_line(primary) != "":
		return
	var line := _read_json_line(backup)
	if line == "":
		return
	var temp := primary + ".restore"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		ModLoaderLog.error("Could not write %s to restore %s from its backup" % [temp, primary], LOG_NAME)
		return
	file.store_string(line)
	file.close()
	DirAccess.rename_absolute(temp, primary)
	ModLoaderLog.warning("%s was missing or corrupt; restored it from %s" % [primary, backup], LOG_NAME)


# The file's first line if it parses as a JSON object (how vanilla reads saves), else "".
static func _read_json_line(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var line := file.get_line()
	file.close()
	var json := JSON.new()
	if json.parse(line) != OK or not json.data is Dictionary:
		return ""
	return line


# True when the mod is enabled and the given fix is switched on.
static func is_on(key: String) -> bool:
	var data: Dictionary = get_config().data
	return bool(data.get("enabled", true)) and bool(data.get(key, true))


# --- Config ---

static func get_config() -> ModConfig:
	const LABEL := "user"
	if ModLoaderConfig.has_config(MOD_ID, LABEL):
		return ModLoaderConfig.get_config(MOD_ID, LABEL)
	return ModLoaderConfig.create_config(MOD_ID, LABEL, ModLoaderConfig.get_default_config(MOD_ID).data)


static func set_fix(key: String, value: bool) -> void:
	var cfg := get_config()
	cfg.data[key] = value
	ModLoaderConfig.update_config(cfg)


static func get_enabled() -> bool:
	return bool(get_config().data.get("enabled", true))


static func set_enabled(value: bool) -> void:
	var cfg := get_config()
	cfg.data["enabled"] = value
	ModLoaderConfig.update_config(cfg)
