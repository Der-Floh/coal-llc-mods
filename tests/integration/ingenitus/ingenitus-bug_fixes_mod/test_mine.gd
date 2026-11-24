extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Fixes checked in the mine: the loot cap during one-frame bursts (also with that item's
# pickup already lying there) and explosions reaching their bottom and right edges.

const MOD_ID := "ingenitus-bug_fixes_mod"
const COAL := "res://resources/Items/Coal.tres"
const COPPER := "res://resources/Items/Minerals/Copper.tres"
# Above the default Max Item Drops (400); thousands would freeze the game without the fix.
const BURST := 800
const CAPPED_PICKUPS := Vector2(400, 405)
const BLAST_CENTER := Vector2i(8, 12)
const BLAST_RADIUS := 3
const BLAST_BOX := 5


func before_each() -> void:
	if await in_mine():
		player().global_position = Vector2(192, 300)


func test_burst_is_capped() -> void:
	expect_eq(await _burst(COAL, false), {"pickups_capped": true, "total": float(BURST)}, "800 coal drops in one frame")


func test_burst_is_capped_with_a_pickup_lying_there() -> void:
	expect_eq(await _burst(COAL, true), {"pickups_capped": true, "total": float(BURST + 1)}, "800 coal drops next to a coal pickup")
	expect_eq(await _burst(COPPER, true), {"pickups_capped": true, "total": float(BURST)}, "800 copper drops next to a coal pickup")


func test_ordinary_drops_are_unchanged() -> void:
	var loot = _loot()
	_clear_pickups(loot)
	await physics_frames(3)
	for i in 20:
		loot.on_drop_loot(_drop_position(), COAL, 15.0)
	await tree.process_frame
	await tree.physics_frame
	expect_eq(_pickups(loot, COAL).size(), 300, "20 drops of 15 coal stay single pickups")
	_clear_pickups(loot)


func test_explosions_reach_their_edges() -> void:
	expect_eq(_blast(func(center: Vector2) -> void: tilemap().on_BombExplode(center, float(BLAST_RADIUS), 1.0e9)), {"destroyed": 29, "bottom_left": false, "right_left": false}, "bomb, radius 3")
	expect_eq(_blast(func(center: Vector2) -> void: tilemap().earthquake_pos(center, 1.0e9, BLAST_RADIUS)), {"destroyed": 29, "bottom_left": false, "right_left": false}, "earthquake, radius 3")
	var bug_fixes = mod(MOD_ID)
	bug_fixes.set_fix("fix_blast_edges", false)
	on_cleanup(func() -> void: bug_fixes.set_fix("fix_blast_edges", true))
	expect_eq(_blast(func(center: Vector2) -> void: tilemap().on_BombExplode(center, float(BLAST_RADIUS), 1.0e9)), {"destroyed": 27, "bottom_left": true, "right_left": true}, "vanilla bomb misses its bottom and right tips")


func _burst(item: String, with_lying_pickup: bool) -> Dictionary:
	var loot = _loot()
	_clear_pickups(loot)
	await physics_frames(3)
	if with_lying_pickup:
		loot.on_drop_loot(_drop_position(), COAL, 1.0)
		await physics_frames(3)
	for i in BURST:
		loot.on_drop_loot(_drop_position(), item, 1.0)
	await tree.process_frame
	await tree.physics_frame
	var pickups := _pickups(loot, item)
	var total: float = pickups.reduce(func(sum: float, pickup) -> float: return sum + pickup.count, 0.0)
	var result := {"pickups_capped": pickups.size() >= CAPPED_PICKUPS.x and pickups.size() <= CAPPED_PICKUPS.y, "total": total}
	if not result.pickups_capped:
		fail("%d %s pickups, expected about 402" % [pickups.size(), item.get_file()])
	_clear_pickups(loot)
	return result


func _blast(explode: Callable) -> Dictionary:
	var tm = tilemap()
	var box := []
	for x in range(BLAST_CENTER.x - BLAST_BOX, BLAST_CENTER.x + BLAST_BOX + 1):
		for y in range(BLAST_CENTER.y - BLAST_BOX, BLAST_CENTER.y + BLAST_BOX + 1):
			box.append(Vector2i(x, y))
	for tile in box:
		tm.change_tile(tile, TileMapChunk.Tiles.BASIC_CLAY)
		tm.damageTileCoords(tile, 1.0)
	explode.call(Vector2(BLAST_CENTER * 16))
	return {
		"destroyed": box.filter(func(tile: Vector2i) -> bool: return not tm.is_tile_alive(tile)).size(),
		"bottom_left": tm.is_tile_alive(BLAST_CENTER + Vector2i(0, BLAST_RADIUS)),
		"right_left": tm.is_tile_alive(BLAST_CENTER + Vector2i(BLAST_RADIUS, 0)),
	}


func _loot():
	return game.current_node.get_node("LootDrops")


func _drop_position() -> Vector2:
	return player().global_position + Vector2(0, -400)


static func _pickups(loot, item: String) -> Array:
	return loot.loot_drops.get_children().filter(func(node) -> bool: return node is ItemPickup and node.pickupItem.resource_path == item)


static func _clear_pickups(loot) -> void:
	for pickup in loot.loot_drops.get_children():
		pickup.queue_free()
