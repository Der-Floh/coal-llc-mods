extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# +100% tick speed makes poison and fire tick twice as often, also on distant (disabled) chunks,
# and Preserve effect duration scales the ticks of new effects so they last as long.

const MOD_ID := "der_floh-tick_upgrade_mod"
const MEASURE_FRAMES := 300
# Every tile is hit once per 30 poison loops or 10 fire loops; the loop counters wrap there.
const POISON_LOOP := 30
const FIRE_LOOP := 10
const FAR_CHUNK_OFFSET := Vector2i(8, 3)
const LASTING_TICKS := 100000


func before_each() -> void:
	if await in_mine():
		mod(MOD_ID).reset_passives()


func after_each() -> void:
	mod(MOD_ID).reset_passives()


func test_double_speed_doubles_ticks_near_and_far() -> void:
	var tiles := _effect_tiles()
	var vanilla := await _count_loops(tiles)
	mod(MOD_ID).set_passive("poison_tick_speed", 1.0)
	mod(MOD_ID).set_passive("fire_tick_speed", 1.0)
	var doubled := await _count_loops(tiles)
	expect_between(doubled.near_poison, vanilla.near_poison * 1.9, vanilla.near_poison * 2.1, "near poison loops %s → %s" % [vanilla.near_poison, doubled.near_poison])
	expect_between(doubled.near_fire, vanilla.near_fire * 1.9, vanilla.near_fire * 2.1, "near fire loops %s → %s" % [vanilla.near_fire, doubled.near_fire])
	expect_between(doubled.far_poison, vanilla.far_poison * 1.9, vanilla.far_poison * 2.1, "far poison loops %s → %s" % [vanilla.far_poison, doubled.far_poison])
	expect(vanilla.far_poison > 0, "distant chunks tick while Always tick distant is on")
	_clear(tiles)


func test_distant_ticking_can_be_switched_off() -> void:
	var tiles := _effect_tiles()
	use_setting(MOD_ID, "always_tick_distant", false)
	var counts := await _count_loops(tiles)
	expect_eq(counts.far_poison, 0, "far poison loops with Always tick distant off")
	expect(counts.near_poison > 0, "near tiles still tick")
	_clear(tiles)


func test_disabled_mod_ticks_like_vanilla() -> void:
	var tiles := _effect_tiles()
	var vanilla := await _count_loops(tiles)
	mod(MOD_ID).set_passive("poison_tick_speed", 1.0)
	use_setting(MOD_ID, "enabled", false)
	var disabled := await _count_loops(tiles)
	expect_between(disabled.near_poison, vanilla.near_poison * 0.9, vanilla.near_poison * 1.1, "near poison loops with the mod disabled")
	expect_eq(disabled.far_poison, 0, "no distant ticking with the mod disabled")
	_clear(tiles)


func test_preserve_duration_scales_new_effects() -> void:
	var tile: Vector2i = _effect_tiles().near
	mod(MOD_ID).set_passive("poison_tick_speed", 1.0)
	mod(MOD_ID).set_passive("fire_tick_speed", 1.0)
	_apply(tile, 3.0, 10)
	expect_eq(_ticks_and_damage(tile), [20, 20, 3.0], "[poison ticks, fire ticks, damage] with Preserve on at 2×")
	use_setting(MOD_ID, "preserve_duration", false)
	_apply(tile, 3.0, 10)
	expect_eq(_ticks_and_damage(tile), [10, 10, 3.0], "with Preserve off")
	tilemap().remove_poison_tile_coords(tile)
	_remove_burn(tile)


func _effect_tiles() -> Dictionary:
	var tm = tilemap()
	var player_chunk: Vector2i = tm.get_chunk_id_pos(player().global_position)
	var near = tm.chunks_created[player_chunk + Vector2i(0, 1)]
	var far_id: Vector2i = player_chunk + FAR_CHUNK_OFFSET
	tm.generate_chunk(far_id.x, far_id.y)
	var far = tm.chunks_created[far_id]
	far.change_state(TileMapChunk.States.DISABLED)
	var tiles := {"near": near.array_to_global_pos(_breakable_index(near)), "far": far.array_to_global_pos(_breakable_index(far)), "near_chunk": near, "far_chunk": far}
	tm.poison_tile_coords(tiles.near, 0.001, LASTING_TICKS)
	tm.burn_tile_coords(tiles.near, 0.001, LASTING_TICKS)
	tm.poison_tile_coords(tiles.far, 0.001, LASTING_TICKS)
	return tiles


func _count_loops(tiles: Dictionary) -> Dictionary:
	var near = tiles.near_chunk
	var far = tiles.far_chunk
	var counts := {"near_poison": 0, "near_fire": 0, "far_poison": 0}
	var last := [near.poison_idx, near.burn_idx, far.poison_idx]
	for i in MEASURE_FRAMES:
		await tree.physics_frame
		var now := [near.poison_idx, near.burn_idx, far.poison_idx]
		counts.near_poison += posmod(now[0] - last[0], POISON_LOOP)
		counts.near_fire += posmod(now[1] - last[1], FIRE_LOOP)
		counts.far_poison += posmod(now[2] - last[2], POISON_LOOP)
		last = now
	expect_eq(far.state, TileMapChunk.States.DISABLED, "the far chunk stayed disabled")
	return counts


func _clear(tiles: Dictionary) -> void:
	var tm = tilemap()
	tm.remove_poison_tile_coords(tiles.near)
	_remove_burn(tiles.near)
	tm.remove_poison_tile_coords(tiles.far)


func _apply(tile: Vector2i, damage: float, ticks: int) -> void:
	var tm = tilemap()
	tm.remove_poison_tile_coords(tile)
	_remove_burn(tile)
	tm.poison_tile_coords(tile, damage, ticks)
	tm.burn_tile_coords(tile, damage, ticks)


func _ticks_and_damage(tile: Vector2i) -> Array:
	var chunk = tilemap().chunks_created[tilemap().get_chunk_id(tile)]
	var i: int = chunk.global_pos_to_array(tile)
	return [chunk.poison_tiles_set[chunk.poison_tiles[i]["poison_idx"]][i], chunk.burn_tiles_set[chunk.burn_tiles[i]["burn_idx"]][i], chunk.poison_tiles[i]["damage"]]


static func _breakable_index(chunk) -> int:
	for i in chunk.tiles.size():
		if TileMapChunk.TILE_PROPERTIES[chunk.tiles[i]]["breakable"]:
			return i
	return 0


# TileMapManager.remove_burn_tile_coords calls a chunk method that doesn't exist; the chunk's own one works.
func _remove_burn(tile: Vector2i) -> void:
	tilemap().chunks_created[tilemap().get_chunk_id(tile)].remove_burn_tile(tile)
