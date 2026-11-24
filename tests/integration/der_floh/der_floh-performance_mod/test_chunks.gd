extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# The faster chunk loading rebuilds the loaded zone only when a chunk loader changes chunk, yet
# every chunk, also one generated in between, has the state of its zone, as in vanilla.

const LOAD_FRAMES := 150
const FAR_AREA := Vector2(-20000, 6000)
const DISTANT_TARGET := Vector2(-40000, 9000)
const SHELLS := 30


func before_each() -> void:
	await in_mine()


func test_chunk_states_match_their_zone_after_loading() -> void:
	expect_eq(await _misclassified(10), [], "chunks whose state doesn't match their zone")
	if not _succeeded(await commands.teleport({"x": FAR_AREA.x, "y": FAR_AREA.y})):
		return
	expect_eq(await _misclassified(LOAD_FRAMES), [], "after loading a new area without crossing a chunk border")


func test_chunks_from_distant_explosions_get_their_state() -> void:
	var mortars = game.current_node.get_node("MortarManager")
	for i in SHELLS:
		mortars.shoot_mortar(DISTANT_TARGET, 1.0)
	expect_eq(await _misclassified(300), [], "after mortar shells land far away")


func _misclassified(wait_frames: int) -> Array:
	await frames(wait_frames)
	var tm = tilemap()
	var wrong := []
	for id in tm.chunks_created:
		var zone_state := TileMapChunk.States.DISABLED
		if tm.live_chunks.has(id):
			zone_state = TileMapChunk.States.LIVE
		elif tm.simple_collision_chunks.has(id):
			zone_state = TileMapChunk.States.NO_COLLISIONS
		if tm.chunks_created[id].state != zone_state and wrong.size() < 5:
			wrong.append([id, tm.chunks_created[id].state, zone_state])
	return wrong
