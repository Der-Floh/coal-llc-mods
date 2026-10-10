class_name IngenitusExtraPassivesMod
extends Node

const MOD_ID := "ingenitus-extra_passives_mod"
const MOD_DIR := "ingenitus-extra_passives_mod"
const LOG_NAME := "ingenitus-extra_passives_mod:Main"

const GUNS := ["pistol", "shotgun", "rifle", "minigun"]

# New passives: step per pick (x the card multiplier, like vanilla's ALL_PASSIVES),
# the item types that make it worth offering, a display name, and an optional cap
# past which it leaves the offer pool (it would do nothing more).
const PASSIVES := {
	"gun_fire_rate": {"step": 0.05, "items": GUNS, "name": "Gun Fire Rate", "cap": 13.0},
	"multi_projectile": {"step": 0.1, "items": GUNS, "name": "Extra Projectiles"},
	"bullet_pierce": {"step": 0.1, "items": GUNS, "name": "Bullet Pierce"},
	"axe_spin_speed": {"step": 0.05, "items": ["axe", "battleaxe"], "name": "Axe Spin-Up Speed"},
	"vacuum_range": {"step": 0.05, "items": [], "vacuum": true, "name": "Vacuum Range"},
	"vacuum_power": {"step": 0.05, "items": [], "vacuum": true, "name": "Vacuum Suction"},
	"drill_speed": {"step": 0.05, "items": ["drill"], "name": "Drill Speed"},
	"earthquake_damage": {"step": 0.05, "items": ["earthquake"], "name": "Earthquake Damage"},
	"earthquake_radius": {"step": 0.05, "items": ["earthquake"], "name": "Earthquake Radius", "cap": 3.8},
	"bomb_radius": {"step": 0.05, "items": ["bomb", "nuke"], "name": "Bomb Radius", "cap": 11.0},
}

# Final blast radius of any bomb or earthquake, in tiles. Chunks stream in a 7x7
# window (range(-3, 4)) of 16-tile chunks around the player, so 3 * 16 = 48 is the
# largest half-width guaranteed to be loaded; past it a blast spends its cost on
# chunks the player cannot see. The stock tactical nuke is 40.
const MAX_BLAST_RADIUS := 48.0
# Fire-rate floor: the gun cooldown never drops below this (seconds). The slowest
# gun (0.7 s) reaches it at +1300%, which is gun_fire_rate's cap.
const GUN_COOLDOWN_FLOOR := 0.05
# Extra projectiles on a gun with no spread would stack on one line.
const MULTI_MIN_SPREAD := 20.0

const SAVE_KEY := "ingenitus_extra_passives"

# Earned levels (0.0 = none) and the player's dial-back of bomb radius. Kept here,
# saved inside the run save by passives.hooks.gd.
static var levels: Dictionary = {}
static var adjusted_bomb_radius: float = 0.0
# Cached config switch; level() runs per bullet per frame.
static var _enabled: bool = true

var mod_dir_path: String
var extensions_dir_path: String


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	extensions_dir_path = mod_dir_path.path_join("extensions")
	_enabled = get_enabled()
	reset_levels()
	install_hooks()


func install_hooks() -> void:
	# Script Extension: Passives exposes the new levels via get()/set() and saves them.
	ModLoaderMod.install_script_extension(
		extensions_dir_path.path_join("resources/passive_effects/passives.gd")
	)

	var hooks := {
		# Offers, buttons, and the passive bonuses panel (Tab).
		"res://scenes/Interfaces/in_game/choose_passive.gd": "scenes/Interfaces/in_game/choose_passive.hooks.gd",
		"res://scenes/Interfaces/Management/passive_bonuses.gd": "scenes/Interfaces/Management/passive_bonuses.hooks.gd",
		# Effects.
		"res://scripts/StateMachine/Player2/player_2.gd": "scripts/StateMachine/Player2/player_2.hooks.gd",
		"res://scripts/Bullet.gd": "scripts/Bullet.hooks.gd",
		"res://scenes/equipment/axe.gd": "scenes/equipment/axe.hooks.gd",
		"res://scenes/equipment/battleaxe.gd": "scenes/equipment/battleaxe.hooks.gd",
		"res://scripts/equipment_manager.gd": "scripts/equipment_manager.hooks.gd",
		"res://scenes/Machinery/drill_bit_2.gd": "scenes/Machinery/drill_bit_2.hooks.gd",
		"res://resources/EquipEffects/Scripts/earthquake_inducer.gd": "resources/EquipEffects/Scripts/earthquake_inducer.hooks.gd",
		"res://scripts/Bomb.gd": "scripts/Bomb.hooks.gd",
	}
	for vanilla_path in hooks:
		ModLoaderMod.install_script_hooks(vanilla_path, extensions_dir_path.path_join(hooks[vanilla_path]))

	# Every profession script gets the same hook, so the new passives join each
	# profession's offer pool (and NanobotZ-AutoPassiveChooser's list).
	var profession_hook := extensions_dir_path.path_join("resources/professions/scripts/profession.hooks.gd")
	for script_name in ["profession", "assassin", "barbarian", "demolitionist", "destructor", "firestarter",
			"generalist", "generalist_plus", "gunslinger", "internship", "lone_ranger", "lumberjack",
			"martial_artist", "maverick", "mule", "orbist", "shaman", "shotgunner", "tanker",
			"ultimate_destructor", "waterbender", "wizard"]:
		ModLoaderMod.install_script_hooks("res://resources/professions/scripts/%s.gd" % script_name, profession_hook)


func _ready() -> void:
	ModLoaderLog.info("Ready! enabled=%s passives=%d" % [str(get_enabled()), PASSIVES.size()], LOG_NAME)


# --- Levels ---

static func level(key: String) -> float:
	if not _enabled:
		return 0.0
	return float(levels.get(key, 0.0))


# Bomb radius as used by bombs: the earned level, dialled back by the player.
static func bomb_radius_in_use() -> float:
	return minf(adjusted_bomb_radius, level("bomb_radius"))


static func add_level(key: String, amount: float) -> void:
	var old: float = float(levels.get(key, 0.0))
	levels[key] = old + amount
	# Keep the dial-back at full while it tracks the earned value (like vanilla's sliders).
	if key == "bomb_radius" and is_equal_approx(adjusted_bomb_radius, old):
		adjusted_bomb_radius = levels[key]


static func reset_levels() -> void:
	for key in PASSIVES:
		levels[key] = 0.0
	adjusted_bomb_radius = 0.0


static func save_data() -> Dictionary:
	return {"levels": levels.duplicate(), "adjusted_bomb_radius": adjusted_bomb_radius}


static func load_data(data: Dictionary) -> void:
	reset_levels()
	var saved: Dictionary = data.get("levels", {})
	for key in PASSIVES:
		levels[key] = float(saved.get(key, 0.0))
	# A save without a dial-back value keeps the full earned radius.
	adjusted_bomb_radius = float(data.get("adjusted_bomb_radius", levels["bomb_radius"]))


# --- Offers ---

# True when the passive is worth offering right now: the player owns an item it
# applies to (or a vacuum), and it is below its cap.
static func offerable(key: String) -> bool:
	if not _enabled or not PASSIVES.has(key):
		return false
	var def: Dictionary = PASSIVES[key]
	if def.has("cap") and float(levels.get(key, 0.0)) >= def["cap"]:
		return false
	if def.get("vacuum", false):
		var bem = Gvars.bonus_equipment_manager
		return bem.current_vacuum != bem.Vacuums.NONE
	# Deliberately untyped: GML compiles mod_main before the game's autoloads, and a
	# typed Inventory reference here would compile Inventory.gd that early, whose
	# preload of the Empty item then loads without its Item script. Every inventory
	# slot operation fails for the rest of the session after that.
	var inventory = load("res://resources/Inventories/PlayerInventory.tres")
	for inv_item in inventory.items:
		if inv_item and inv_item.item and inv_item.item.itemType in def["items"]:
			return true
	return false


static func label_text(key: String, amount: float) -> String:
	return "Increase " + PASSIVES[key]["name"] + " +" + str(roundi(amount * 100)) + "%"


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
