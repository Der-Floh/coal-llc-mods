extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Chunk Load Radius r loads (2r+1)² chunks around the player, only the inner 3×3 with full
# collision, and Chunks Generated Per Frame sets how fast new ones are made. Works with and
# without the Performance Mod, which then uses these settings.

const MOD_ID := "der_floh-game_limits_mod"
const FAR_AREA := Vector2(64128, 3200)
const OTHER_FAR_AREA := Vector2(-64128, 3200)
const SETTLE_FRAMES := 90


func before_each() -> void:
	await in_mine()


func test_radius_loads_a_ring_without_collision() -> void:
	await _move_to(FAR_AREA)
	use_setting(MOD_ID, "chunks_per_frame", 10)
	use_setting(MOD_ID, "chunk_load_radius", 5)
	await frames(SETTLE_FRAMES)
	expect_eq(_zone_census(5), {"live": 9, "ring": 112, "wrong": 0}, "chunks around the player at radius 5")


func test_disabled_mod_loads_the_vanilla_radius() -> void:
	await _move_to(FAR_AREA)
	use_setting(MOD_ID, "chunks_per_frame", 10)
	use_setting(MOD_ID, "chunk_load_radius", 5)
	use_setting(MOD_ID, "enabled", false)
	await frames(SETTLE_FRAMES)
	expect_eq(_zone_census(3), {"live": 9, "ring": 40, "wrong": 0}, "chunks around the player with the mod disabled")


func test_chunks_per_frame() -> void:
	await _move_to(OTHER_FAR_AREA)
	use_setting(MOD_ID, "chunk_load_radius", 10)
	use_setting(MOD_ID, "chunks_per_frame", 7)
	await frames(2)
	var tm = tilemap()
	var created := []
	for i in 4:
		created.append(tm.chunks_created.size())
		await frames()
	expect_eq([created[1] - created[0], created[2] - created[1], created[3] - created[2]], [7, 7, 7], "new chunks per frame")


func _move_to(position: Vector2) -> void:
	_succeeded(await commands.teleport({"x": position.x, "y": position.y}))


# Chunks within r of the player's chunk: full collision for the inner 3×3, the ring state outside it.
func _zone_census(radius: int) -> Dictionary:
	var tm = tilemap()
	var center: Vector2i = tm.get_chunk_id_pos(player().global_position)
	var census := {"live": 0, "ring": 0, "wrong": 0}
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			var id := center + Vector2i(dx, dy)
			var inner := maxi(absi(dx), absi(dy)) <= 1
			var state = tm.chunks_created[id].state if tm.chunks_created.has(id) else -1
			if inner and state == TileMapChunk.States.LIVE:
				census.live += 1
			elif not inner and state == TileMapChunk.States.NO_COLLISIONS:
				census.ring += 1
			else:
				census.wrong += 1
	return census
