extends Object

# fix_loot_duplication. A pickup that has been merged into another, or fully
# collected, is only queue_free()d, so it stays in the tree until the end of the
# frame. Vanilla never checks for that, so in the same frame:
#   - another pickup can merge it again and add its count a second time;
#   - a collector, the stockpile or the player can collect it after its count was
#     already merged away.
# Collecting also cannot zero `count` (its setter ignores values <= 0), so a fully
# collected pickup still carries its whole count. Such pickups are marked with the
# existing `being_merged` flag and skipped by merges and pickups.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-bug_fixes_mod/mod_main.gd"


func mergeWithNeighbours(chain: ModLoaderHookChain) -> void:
	if not load(MOD_MAIN_PATH).is_on("fix_loot_duplication"):
		chain.execute_next()
		return
	var pickup := chain.reference_object as ItemPickup
	if _is_spent(pickup):
		return
	# Same rule as vanilla (absorb matching neighbours whose count does not exceed
	# ours), skipping neighbours that are already spent.
	for body in pickup.item_pickup.get_overlapping_bodies():
		if body is ItemPickup and body != pickup and not _is_spent(body) \
				and body.pickupItem == pickup.pickupItem and body.count <= pickup.count:
			pickup.count += body.count
			body.being_merged = true
			body.queue_free()


func _on_item_pickup_body_entered(chain: ModLoaderHookChain, body: Node2D) -> void:
	if not load(MOD_MAIN_PATH).is_on("fix_loot_duplication"):
		chain.execute_next([body])
		return
	var pickup := chain.reference_object as ItemPickup
	if _is_spent(pickup):
		return
	chain.execute_next([body])
	_mark_if_collected(pickup)


func _on_item_pickup_area_entered(chain: ModLoaderHookChain, area: Area2D) -> void:
	if not load(MOD_MAIN_PATH).is_on("fix_loot_duplication"):
		chain.execute_next([area])
		return
	var pickup := chain.reference_object as ItemPickup
	if _is_spent(pickup):
		return
	chain.execute_next([area])
	_mark_if_collected(pickup)


static func _is_spent(pickup: ItemPickup) -> bool:
	return pickup.being_merged or pickup.is_queued_for_deletion()


# Vanilla hides a pickup when it is fully collected (and frees it), never otherwise.
static func _mark_if_collected(pickup: ItemPickup) -> void:
	if not pickup.visible:
		pickup.being_merged = true
