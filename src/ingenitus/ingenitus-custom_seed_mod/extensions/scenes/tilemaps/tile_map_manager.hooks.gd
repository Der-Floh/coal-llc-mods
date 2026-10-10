extends Object

# Vanilla seeds a level once from entropy (initialise_level: randomize(), then
# noise.seed = randi()) and generates chunks in streaming order from the shared
# global RNG. That RNG drives layer-boundary jitter, sparse-map tile skips, sprite
# variants and chest count/placement, so even a fixed noise seed would give a
# different mine depending on the order you explore it.
#
# With a seed set, every chunk generation is seeded from (seed, day, chunk
# position) instead, so each chunk comes out identical however you get there.
# The global RNG is re-randomised afterwards, so the rest of gameplay stays random.
# Seed 0 (or the mod disabled) leaves vanilla untouched.

const LOG_NAME := "ingenitus-custom_seed_mod:TileMapManagerHook"
# Access mod_main via load() — a mod's class_name is not in GDScript's global
# registry, so referencing IngenitusCustomSeedMod here would not compile.
const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-custom_seed_mod/mod_main.gd"


# Level start: take the seed settings for this whole mine, then build it.
func initialise_level(chain: ModLoaderHookChain) -> void:
	load(MOD_MAIN_PATH).begin_level()
	chain.execute_next()


# Full generation of a new chunk (initial level and streaming).
func generate_chunk(chain: ModLoaderHookChain, chunk_x, chunk_y) -> void:
	var manager := chain.reference_object as TileMapManager
	var chunk_id := Vector2i(chunk_x, chunk_y)
	if manager.chunks_created.has(chunk_id) or not _seed_chunk(manager, chunk_id):
		chain.execute_next([chunk_x, chunk_y])
		return
	chain.execute_next([chunk_x, chunk_y])
	randomize()


# Tiles and chests for a chunk that was created blank first.
func generate_chunk_tiles(chain: ModLoaderHookChain, chunk_id: Vector2i) -> void:
	var manager := chain.reference_object as TileMapManager
	if not _seed_chunk(manager, chunk_id):
		chain.execute_next([chunk_id])
		return
	chain.execute_next([chunk_id])
	randomize()


static func _seed_chunk(manager: TileMapManager, chunk_id: Vector2i) -> bool:
	var mod_main = load(MOD_MAIN_PATH)
	var s: int = mod_main.chunk_seed(chunk_id)
	if s < 0:
		return false
	manager.noise.seed = mod_main.noise_seed()
	seed(s)
	if mod_main.get_debug_logging():
		ModLoaderLog.debug("chunk %s seeded %d (noise %d)" % [str(chunk_id), s, manager.noise.seed], LOG_NAME)
	return true
