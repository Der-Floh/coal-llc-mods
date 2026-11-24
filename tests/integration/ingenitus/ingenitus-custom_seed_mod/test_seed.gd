extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# The same non-zero seed builds the same mine on the same day, whatever order chunks are
# generated in; each day gets a new seeded mine unless "Same mine every day" is on, and seed 0
# leaves mines random. The seed lives in the mod config, not the save.

const MOD_ID := "ingenitus-custom_seed_mod"
const PASSIVE_DROP_ID := "der_floh-passive_drop_mod"
const SEED := 12345
const FAR_CHUNKS := [Vector2i(20, 20), Vector2i(21, 20)]
const FINGERPRINT_CHUNKS := [Vector2i(-2, 0), Vector2i(0, 0), Vector2i(1, 1), Vector2i(20, 20), Vector2i(21, 20)]
const SETTLE_FRAMES := 20


func before_each() -> void:
	if await fresh_run() and has_mod(PASSIVE_DROP_ID):
		use_setting(PASSIVE_DROP_ID, "chest_generation_enabled", true)


func test_same_seed_and_day_build_the_same_mine() -> void:
	use_setting(MOD_ID, "seed", SEED)
	var first := await _day_fingerprint(1, FAR_CHUNKS)
	var reversed_order := FAR_CHUNKS.duplicate()
	reversed_order.reverse()
	var replay := await _day_fingerprint(1, reversed_order)
	expect_eq(replay, first, "day 1 replayed, far chunks generated in the other order")
	expect(await _day_fingerprint(2, FAR_CHUNKS) != first, "day 2 gets a new seeded mine")


func test_same_mine_every_day() -> void:
	use_setting(MOD_ID, "seed", SEED)
	use_setting(MOD_ID, "same_every_day", true)
	expect_eq(await _day_fingerprint(3, FAR_CHUNKS), await _day_fingerprint(4, FAR_CHUNKS), "days 3 and 4")


func test_seed_zero_keeps_mines_random() -> void:
	use_setting(MOD_ID, "seed", 0)
	expect(await _day_fingerprint(1, FAR_CHUNKS) != await _day_fingerprint(1, FAR_CHUNKS), "two replays of day 1 differ")


func test_seed_is_kept_in_the_config_not_the_save() -> void:
	use_setting(MOD_ID, "seed", SEED)
	gvars.save_game()
	expect(FileAccess.get_file_as_string(mod(MOD_ID).get_config().save_path).contains(str(SEED)), "the config file holds the seed")
	expect(not FileAccess.get_file_as_string("user://v04_savegame.save").contains(str(SEED)), "the run save doesn't")


func test_seed_box_takes_up_to_nine_digits() -> void:
	var menu = await open_settings()
	var box: LineEdit = menu.tab_container.get_node("World Seed").find_children("*", "LineEdit", true, false).front()
	box.text = "12a3456789012"
	box.text_changed.emit(box.text)
	on_cleanup(func() -> void: mod(MOD_ID).set_seed(0))
	expect_eq([box.text, mod(MOD_ID).get_seed()], ["123456789", 123456789], "[box text, stored seed] after typing 12a3456789012")


# Replays a day: the day count is set so the next start is that day, then the mine is fingerprinted.
func _day_fingerprint(day: int, far_order: Array) -> int:
	if not await in_management():
		return 0
	gvars.dayCount = day - 1
	if not _succeeded(await commands.start_day({})):
		return 0
	await frames(SETTLE_FRAMES)
	var tm = tilemap()
	for id in far_order:
		tm.generate_chunk(id.x, id.y)
	await frames()
	var parts := []
	for id in FINGERPRINT_CHUNKS:
		var chunk = tm.chunks_created[id]
		var variants := []
		for i in chunk.chunk_size * chunk.chunk_size:
			variants.append(chunk.get_cell_alternative_tile(chunk.array_to_pos(i)))
		var chests: Array = chunk.get_children().filter(func(node) -> bool: return node is Chest).map(func(chest) -> Array: return [chest.position, chest.loot_level])
		parts.append([hash(chunk.tiles), hash(variants), chests])
	var fingerprint := hash(parts)
	_succeeded(await commands.end_day({}))
	return fingerprint
