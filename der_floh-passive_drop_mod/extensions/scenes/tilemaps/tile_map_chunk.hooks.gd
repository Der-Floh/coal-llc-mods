extends Object

const LOG_NAME := "der_floh-passive_drop_mod:Hook"

const PASSIVE_RES_PATH := "res://resources/Items/power_ups/PassiveUpgrade.tres"

# Maps the ore-name prefix found in loot strings (e.g. "pinkDiamond" from
# "pinkDiamond_dark") to the config key used by mod_main (e.g. "pink_diamond").
# Loot string format: "<ore_name>_<depth_suffix>".
const _LOOT_ORE_TO_KEY := {
	"coal":        "coal",
	"copper":      "copper",
	"iron":        "iron",
	"silver":      "silver",
	"gold":        "gold",
	"amethyst":    "amethyst",
	"sapphire":    "sapphire",
	"emerald":     "emerald",
	"ruby":        "ruby",
	"diamond":     "diamond",
	"pinkDiamond": "pink_diamond",
	"spinel":      "spinel",
	"uranium":     "uranium",
	"moonstone":   "moonstone",
	"onyx":        "onyx",
}


func destroy_tile(chain: ModLoaderHookChain, idx: int, tile_properties: Dictionary) -> void:
	var chunk := chain.reference_object as TileMapChunk

	chain.execute_next([idx, tile_properties])

	var mod_main := load("res://mods-unpacked/der_floh-passive_drop_mod/mod_main.gd")
	if not mod_main.get_enabled():
		return

	var loot: String = tile_properties.get("loot", "none")

	# Determine which per-ore config key to consult.
	# Non-ore tiles (loot == "none") use the "non_ore" key.
	var config_key: String
	if loot == "none":
		config_key = "non_ore"
	else:
		# Loot strings are "<ore_name>_<depth>" — extract everything before the last "_".
		var sep := loot.rfind("_")
		var ore_name := loot.left(sep) if sep >= 0 else loot
		config_key = _LOOT_ORE_TO_KEY.get(ore_name, "")

	if config_key.is_empty():
		return  # Unrecognised tile type — don't drop

	var chance: float = float(mod_main.get_chance_for_key(config_key)) / 100.0
	if chance <= 0.0 or randf() >= chance:
		return

	# Depth-based passive quality: mirror the loot_level system that chests use.
	# Deeper tiles belong to higher-tier hard-block zones → better passive multiplier.
	var tile_pos := chunk.array_to_pos(idx)
	var adj_level: int = chunk.adjust_level_bonus(
		chunk.lvl_from_global_pos(chunk.pos_to_global_pos(tile_pos)),
		Gvars.bonus_equipment_manager.shift_layers_up
	)
	var block_type: TileMapChunk.Tiles = chunk.chest_block_from_level(adj_level)
	var loot_level: int = TileMapChunk.CHEST_LEVEL.get(block_type, 1)
	# Same multiplier formula as Chest.roll_loot(): moderate scaling up to level 4,
	# then quadratic growth for the deeper exotic-material layers.
	var multiplier: float = float(loot_level) if loot_level <= 4 else float(loot_level ** 2)

	# Duplicate so we can assign a multiplier without modifying the shared resource.
	var passive: Item = load(PASSIVE_RES_PATH).duplicate(true)
	passive.itemPickupEffect.multiplier = multiplier

	if mod_main._debug:
		ModLoaderLog.info(
			"Passive drop: loot=%s config_key=%s loot_level=%d multiplier=%.0f" % [
				loot, config_key, loot_level, multiplier
			], LOG_NAME
		)

	if mod_main.get_auto_collect_passives():
		# Directly invoke the pickup effect instead of spawning a world item.
		# This triggers Bus.choose_passive immediately, which NanobotZ-AutoPassiveChooser
		# intercepts to auto-select the best passive without player interaction.
		passive.itemPickupEffect.pickupEffect(passive)
	else:
		# Spawn the passive as a world item the player walks over to collect.
		var world_pos: Vector2 = chunk.to_global(chunk.map_to_local(chunk.array_to_pos(idx)))
		var scatter := Vector2(randf_range(-8.0, 8.0), randf_range(-8.0, 8.0))
		Bus.drop_loot_chest.emit(world_pos + scatter, passive, 1)


func generate_chests(chain: ModLoaderHookChain, current_block_chest_locations: Array[Vector2i]) -> Array:
	var mod_main := load("res://mods-unpacked/der_floh-passive_drop_mod/mod_main.gd")
	if not mod_main.get_enabled() or not mod_main.get_chest_generation_enabled():
		return current_block_chest_locations

	chain.execute_next([current_block_chest_locations])
	return current_block_chest_locations
