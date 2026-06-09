extends Object

const LOG_NAME := "der_floh-no_holes_mod:ChunkHook"
# Access mod_main via load() — dynamically-loaded class_name declarations are not
# in GDScript's global registry, so referencing DerFlohNoHolesMod by name here
# silently prevents hook registration.
const MOD_MAIN_PATH := "res://mods-unpacked/der_floh-no_holes_mod/mod_main.gd"

static var _fill_tile_by_level: Array = []
static var _cache_built: bool = false


static func _build_fill_cache() -> void:
	if _cache_built:
		return
	_cache_built = true
	_fill_tile_by_level.resize(20)
	# Walk GENERATIVE_TILES forward so the last BASIC_* entry per level wins,
	# matching vanilla's "last match wins" semantics.
	for tile in TileMapChunk.GENERATIVE_TILES:
		var props: Dictionary = TileMapChunk.TILE_PROPERTIES[tile]
		var mn: int = props["min_level"]
		var mx: int = props["max_level"]
		if mn < 0 or mx < 0:
			continue  # disabled ore slot, never placed
		if props.get("loot", "") != "none":
			continue  # BASIC_* background tiles are identified by loot == "none"
		for lvl in range(mn, mini(mx, 19) + 1):
			_fill_tile_by_level[lvl] = tile


func generate_chunk(chain: ModLoaderHookChain, noise: Noise) -> void:
	var chunk := chain.reference_object as TileMapChunk
	chain.execute_next([noise])
	_build_fill_cache()
	var holes_filled: int = 0

	for idx in range(0, chunk.chunk_size * chunk.chunk_size):
		if chunk.tiles[idx] != TileMapChunk.Tiles.EMPTY:
			continue

		var xy: Vector2i = chunk.array_to_global_pos(idx)
		var lvl: int = chunk.lvl_from_global_pos(xy)
		lvl = chunk.adjust_level_bonus(lvl, Gvars.bonus_equipment_manager.shift_layers_up)

		if lvl < 0:
			continue  # overground — intentionally empty sky/surface

		var fill: TileMapChunk.Tiles = _fill_tile_by_level[clampi(lvl, 0, 19)]
		if fill == null:
			continue  # safety: no BASIC_* tile defined for this level
		chunk.tiles[idx] = fill
		chunk.build_tile(idx)
		holes_filled += 1

	if holes_filled == 0:
		return

	if load(MOD_MAIN_PATH)._debug:
		ModLoaderLog.info("Chunk %s: filled %d hole(s)" % [str(chunk.chunk_id), holes_filled], LOG_NAME)
