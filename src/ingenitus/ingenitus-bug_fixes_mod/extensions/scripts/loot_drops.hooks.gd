extends Object

# fix_loot_burst. on_drop_loot caps world loot with Gvars.live_loot_count: above
# settings.max_item_drops a drop is merged into an existing pickup of the same item
# instead of spawning a new one. But that count is only refreshed once per physics
# frame, and new pickups are added with call_deferred, so they are not children yet
# either. A nuke or earthquake destroys thousands of tiles in one frame: every drop
# in the burst sees the stale count, finds nothing to merge into, and thousands of
# pickups spawn at once.
#
# The pickups vanilla queued this frame are now counted here and added to the
# stale count for the cap decision. Once that total reaches the cap and vanilla has
# no existing pickup of the item to merge into, the rest of the frame's drops of
# that item are bundled and handed to vanilla as one drop at the end of the frame.
# No loot is lost. Gvars.live_loot_count itself is left alone: vanilla's 200-item
# split and merge thresholds read it too, and raising it mid-frame made those
# engage early in ordinary play, far below the cap.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-bug_fixes_mod/mod_main.gd"
const MERGEABLE_LIVE_LOOT_COUNT := 200  # LootDropsManager.MERGEABLE_LIVE_LOOT_COUNT

# itemResPath -> {"pos": Vector2, "count": float}, drops held back this frame.
static var _held: Dictionary = {}
static var _flushing: bool = false
# Pickups vanilla queued during physics frame _queued_frame (not children yet).
static var _queued: int = 0
static var _queued_frame: int = -1


func on_drop_loot(chain: ModLoaderHookChain, pos: Vector2, itemResPath: String, count: float, dropped_by_player: bool = false) -> void:
	var manager = chain.reference_object
	if _flushing or not load(MOD_MAIN_PATH).is_on("fix_loot_burst"):
		chain.execute_next([pos, itemResPath, count, dropped_by_player])
		return
	var vanilla_count: int = Gvars.live_loot_count
	if vanilla_count + _queued_this_frame() > Gvars.settings.max_item_drops and not dropped_by_player \
			and not _straight_to_stockpile(manager, itemResPath) \
			and not _has_live_pickup(manager, itemResPath):
		_hold(manager, pos, itemResPath, count)
		return
	chain.execute_next([pos, itemResPath, count, dropped_by_player])
	_add_queued(_queued_by_vanilla(manager, itemResPath, count, dropped_by_player, vanilla_count))


static func _queued_this_frame() -> int:
	return _queued if _queued_frame == Engine.get_physics_frames() else 0


static func _add_queued(n: int) -> void:
	var frame := Engine.get_physics_frames()
	if _queued_frame != frame:
		_queued_frame = frame
		_queued = 0
	_queued += n


static func _hold(manager, pos: Vector2, itemResPath: String, count: float) -> void:
	if _held.is_empty():
		_flush.bind(manager).call_deferred()
	if _held.has(itemResPath):
		_held[itemResPath].count += count
		_held[itemResPath].pos = pos  # vanilla's valve also moves the pickup to the latest drop
	else:
		_held[itemResPath] = {"pos": pos, "count": count}


static func _flush(manager) -> void:
	var held := _held
	_held = {}
	if not is_instance_valid(manager):
		return
	_flushing = true
	for path in held:
		manager.on_drop_loot(held[path].pos, path, held[path].count, false)
	_flushing = false


static func _straight_to_stockpile(manager, itemResPath: String) -> bool:
	return manager.straight_to_stockpile and load(itemResPath).itemType in ["gem", "mineral", "coal"]


# Vanilla's valve can only merge into pickups that are already children.
static func _has_live_pickup(manager, itemResPath: String) -> bool:
	for loot in manager.loot_drops.get_children():
		if loot is ItemPickup and loot.pickupItem.resource_path == itemResPath:
			return true
	return false


# How many pickups the vanilla call just queued, following its branches (which
# read the unmodified Gvars.live_loot_count, passed in as live).
static func _queued_by_vanilla(manager, itemResPath: String, count: float, dropped_by_player: bool, live: int) -> int:
	if _straight_to_stockpile(manager, itemResPath):
		return 0
	if live > Gvars.settings.max_item_drops and not dropped_by_player and _has_live_pickup(manager, itemResPath):
		return 0  # merged into an existing pickup
	var bundle_above: float = 10.0 if live > MERGEABLE_LIVE_LOOT_COUNT else 20.0
	return int(count) if count <= bundle_above else 1
