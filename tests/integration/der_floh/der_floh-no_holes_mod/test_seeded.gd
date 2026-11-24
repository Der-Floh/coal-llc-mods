extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# With a Custom Seed, the filled mine is the same every time the seed is replayed.

const SEED_ID := "ingenitus-custom_seed_mod"
const SEED := 4242
const FINGERPRINT_CHUNKS := [Vector2i(-2, 0), Vector2i(0, 0), Vector2i(1, 1), Vector2i(0, 2)]


func test_seeded_mine_is_reproducible() -> void:
	if not require_mods([SEED_ID]) or not await fresh_run():
		return
	use_setting(SEED_ID, "seed", SEED)
	use_setting(SEED_ID, "same_every_day", true)
	var first := await _next_day_fingerprint()
	var second := await _next_day_fingerprint()
	expect(first != 0, "a fingerprint was taken")
	expect_eq(second, first, "the next seeded day builds the same mine")


func _next_day_fingerprint() -> int:
	if not await in_management() or not _succeeded(await commands.start_day({})):
		return 0
	await frames(30)
	var tm = tilemap()
	return hash(FINGERPRINT_CHUNKS.map(func(id: Vector2i): return hash(tm.chunks_created[id].tiles) if tm.chunks_created.has(id) else 0))
