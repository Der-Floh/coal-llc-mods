extends Object
# Optimises the four hottest paths inside TileMapChunk:
#
# generate_chunk():
#   - Replaces the 192-tile inner loop (no break) with a per-level pre-filtered
#     bucket (≤16 tiles) sorted rarest-first, then breaks on first noise match.
#     Equivalent result: the rarest ore that passes its noise test wins, same as
#     the original "last in array wins" semantics. SPARSE levels keep vanilla's
#     per-tile coin flips (one randf() per passing tile, no break).
#   - Inlines the set_cell() call so build_tile() is not called during initial
#     generation, removing the duplicate tiles_health write and the dead
#     atlas-coord early-return check (always misses on fresh chunks, source=-1).
#   - Falls back to vanilla for the `only_coal` hard modifier (complex path,
#     not worth duplicating here).
#
# lvl_from_global_pos_TIGHTFUNNEL():
#   - Computes the funnel distance once instead of in every elif branch. The
#     other variants stay vanilla (see the note above TIGHTFUNNEL below).
#
# generate_chests():
#   - Replaces the blocking synchronous load("res://scenes/Chest.tscn") with a
#     const preload so the resource is only loaded from disk once at startup.

const LOG_NAME := "der_floh-performance_mod:ChunkHook"

# Preloaded once; eliminates the blocking load() call per chest per chunk.
const CHEST_SCENE: PackedScene = preload("res://scenes/Chest.tscn")

# Per-level tile buckets built lazily on first generate_chunk call.
# _tiles_by_level[lvl] contains only the TileMapChunk.Tiles entries whose
# min_level <= lvl <= max_level, ordered in REVERSE GENERATIVE_TILES index
# order (rarest/highest-index first) so the first noise-passing tile wins —
# identical semantics to the original "last tile wins" full-array scan.
static var _tiles_by_level: Array = []  # Array[Array], indexed 0..19
static var _cache_built: bool = false


static func _build_tiles_cache() -> void:
	if _cache_built:
		return
	_cache_built = true
	_tiles_by_level.resize(20)
	for i in 20:
		_tiles_by_level[i] = []
	# Iterate GENERATIVE_TILES in reverse so each bucket arrives rarest-first.
	var gen_tiles: Array = TileMapChunk.GENERATIVE_TILES
	for i in range(gen_tiles.size() - 1, -1, -1):
		var tile = gen_tiles[i]
		var props: Dictionary = TileMapChunk.TILE_PROPERTIES[tile]
		var mn: int = props["min_level"]
		var mx: int = props["max_level"]
		if mn < 0 or mx < 0:
			continue  # tile not used in world generation
		for lvl in range(mn, mini(mx, 19) + 1):  # cap at 19 (deepest valid level)
			_tiles_by_level[lvl].append(tile)


# ── generate_chunk ────────────────────────────────────────────────────────────

func generate_chunk(chain: ModLoaderHookChain, noise: Noise) -> void:
	var chunk := chain.reference_object as TileMapChunk

	var _data: Dictionary = {"only_coal": false, "only_clay": false}
	_data = Gvars.hard_modifier._hard_modifier_effect(_data)

	# The only_coal path uses a complex biome-remapping loop; fall back to vanilla.
	if _data["only_coal"]:
		chain.execute_next([noise])
		return

	_build_tiles_cache()
	chunk.initialise_tiles_array()

	var is_sparse: bool = Gvars.level in [Gconsts.Level.SPARSE, Gconsts.Level.SPARSE_SKY_MINE]
	var is_sky_mine: bool = Gvars.level in [Gconsts.Level.SKY_MINE, Gconsts.Level.SPARSE_SKY_MINE]

	for idx in range(0, chunk.chunk_size * chunk.chunk_size):
		var xy: Vector2i = chunk.array_to_global_pos(idx)
		var lvl: int = chunk.lvl_from_global_pos(xy)
		lvl = chunk.adjust_level_bonus(lvl, Gvars.bonus_equipment_manager.shift_layers_up)

		var chosen_tile: TileMapChunk.Tiles = TileMapChunk.Tiles.EMPTY

		if lvl == -2:
			if is_sky_mine:
				chosen_tile = chunk.generate_overground_skymine(xy)
			else:
				chosen_tile = chunk.generate_overground(xy)
		else:
			# only_clay forces everything into the clay biome (level 1).
			var effective_lvl: int = clampi(1 if _data["only_clay"] else lvl, 0, 19)  # must be a valid bucket index

			var bucket: Array = _tiles_by_level[effective_lvl]
			if is_sparse:
				# Vanilla rolls randf() for EVERY noise-passing tile, in
				# GENERATIVE_TILES order, and the last success wins. Walk the
				# bucket in that order without breaking, so the same draws are
				# consumed and the global RNG stream stays in step with vanilla.
				for i in range(bucket.size() - 1, -1, -1):
					var tile = bucket[i]
					var tp: Dictionary = TileMapChunk.TILE_PROPERTIES[tile]
					if (tp["rarity"] * 2.0) - 1.0 > noise.get_noise_3d(xy.x, xy.y, tp["noiseZIndex"]):
						if randf() < 0.5:  # SPARSE levels randomly skip half the tiles
							chosen_tile = tile
			else:
				# No RNG involved: iterate rarest first and break on the first
				# noise match, which is the tile vanilla's full scan keeps last.
				for tile in bucket:
					var tp: Dictionary = TileMapChunk.TILE_PROPERTIES[tile]
					if (tp["rarity"] * 2.0) - 1.0 > noise.get_noise_3d(xy.x, xy.y, tp["noiseZIndex"]):
						chosen_tile = tile
						break

		chunk.tiles[idx] = chosen_tile
		var props: Dictionary = TileMapChunk.TILE_PROPERTIES[chosen_tile]

		# Write health (build_tile() would do this again — we inline to avoid it).
		chunk.tiles_health[idx] = props["max_health"] if props["breakable"] else 1

		# Inline set_cell() — skips the dead atlas-coord early-return in build_tile()
		# which always misses on fresh chunks (every cell starts with source = -1).
		var tile_data_arr: Array = TileMapChunk.TILE_DATA[chosen_tile]
		var tile_choice: int = randi_range(0, tile_data_arr.size() - 1)  # random atlas sprite variant
		var td: Dictionary = tile_data_arr[tile_choice]
		var pos: Vector2i = chunk.array_to_pos(idx)
		var alternative: int = randi_range(0, props["alts"] - 1)  # random sprite rotation/flip
		if alternative > 7:  # guard matches vanilla's safety check
			chunk.set_cell(pos, td["source"], td["coordinates"], 0)
		else:
			chunk.set_cell(pos, td["source"], td["coordinates"], alternative)
	# chain.execute_next() intentionally omitted — fully replaces vanilla.


# ── lvl_from_global_pos variants ─────────────────────────────────────────────
# STANDARD/FUNNEL/SKY_MINE/SHALLOW are deliberately NOT hooked. Vanilla draws a
# fresh randf() jitter for every depth threshold it tests, so layer boundaries
# are a noisy band and a tile consumes a variable number of RNG draws. Sharing
# one draw per tile sharpens those bands and shifts the global RNG stream for
# everything generated after it (sparse-level tile skips, sprite variants,
# chests), so the "optimised" versions produced different terrain. Keeping the
# per-threshold draws leaves nothing worth optimising, so vanilla runs as is.
# TIGHTFUNNEL has no random jitter, so hoisting the distance is exact.


func lvl_from_global_pos_TIGHTFUNNEL(chain: ModLoaderHookChain, pos: Vector2i) -> int:
	var x := pos.x
	var y := pos.y
	if y < 0:
		return -2
	var d: int = absi(x - 14)  # horizontal distance from funnel center; compute once
	if   d < 3:   return 0
	elif d < 5:   return 1
	elif d < 7:   return 2
	elif d < 9:   return 3
	elif d < 11:  return 4
	elif d < 13:  return 5
	elif d < 15:  return 6
	elif d < 17:  return 7
	elif d < 19:  return 8
	elif d < 21:  return 9
	elif d < 23:  return 10
	elif d < 75:  return 11
	elif d < 100: return 12
	elif d < 125: return 13
	elif d < 150: return 14
	elif d < 175: return 15
	elif d < 200: return 16
	elif d < 225: return 17
	elif d < 250: return 18
	else: return 19


# ── generate_chests ───────────────────────────────────────────────────────────
# Identical to vanilla except CHEST_SCENE (preloaded at startup) replaces the
# blocking synchronous load("res://scenes/Chest.tscn") call per chest.

func generate_chests(chain: ModLoaderHookChain, current_block_chest_locations: Array[Vector2i]) -> Array:
	var chunk := chain.reference_object as TileMapChunk

	var dungeon_width: int = 3
	var dungeon_height: int = 3

	var start_tile := Vector2i(0, 0)
	start_tile.x = randi_range(0, chunk.chunk_size - dungeon_width)
	start_tile.y = randi_range(0, chunk.chunk_size - dungeon_height)

	for n in range(10):
		if start_tile in current_block_chest_locations:
			start_tile.x = randi_range(0, chunk.chunk_size - dungeon_width)
			start_tile.y = randi_range(0, chunk.chunk_size - dungeon_height)
			if n == 9:
				Game.log_message(
					"Script: Standard.gd in TileMapLayer_Main: Cannot fit chest in chunk, not enough space, while loop broken",
					Game.LogLvl.HIGH, Game.LogType.WARNING
				)
				return current_block_chest_locations

	for x in range(start_tile.x - dungeon_width, start_tile.x + dungeon_width):
		for y in range(start_tile.y - dungeon_height, start_tile.y + dungeon_height):
			current_block_chest_locations.append(Vector2i(x, y))

	var chest_level: int = chunk.adjust_level_bonus(
		chunk.lvl_from_global_pos(chunk.pos_to_global_pos(start_tile)),
		Gvars.bonus_equipment_manager.shift_layers_up
	)
	var chest_level_check: int = chunk.adjust_level_bonus(
		chunk.lvl_from_global_pos(chunk.pos_to_global_pos(start_tile + Vector2i(dungeon_width - 1, dungeon_width - 1))),
		Gvars.bonus_equipment_manager.shift_layers_up
	)

	var wall_tile: TileMapChunk.Tiles = chunk.chest_block_from_level(chest_level)
	var wall_tile_check: TileMapChunk.Tiles = chunk.chest_block_from_level(chest_level_check)
	if wall_tile == TileMapChunk.Tiles.EMPTY or wall_tile_check == TileMapChunk.Tiles.EMPTY:
		return current_block_chest_locations

	var wall_tiles: Array = TileMapChunk.TILE_DATA[wall_tile]
	@warning_ignore("unused_variable")
	var tile_count: int = wall_tiles.size()

	for x in range(start_tile.x, start_tile.x + dungeon_width):
		for y in range(start_tile.y, start_tile.y + dungeon_height):
			var idx: int = chunk.pos_to_array(Vector2i(x, y))
			if (x == start_tile.x + 1) and (y == start_tile.y + 1):
				chunk.tiles[idx] = TileMapChunk.Tiles.EMPTY
				chunk.build_tile(idx)
				var instance = CHEST_SCENE.instantiate()  # preloaded — no blocking load()
				instance.position = chunk.map_to_local(Vector2i(x, y))
				instance.loot_level = TileMapChunk.CHEST_LEVEL[wall_tile]
				chunk.add_child.call_deferred(instance)
			else:
				chunk.tiles[idx] = wall_tile
				chunk.build_tile(idx)

	return current_block_chest_locations
	# chain.execute_next() intentionally omitted — fully replaces vanilla.
