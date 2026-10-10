extends Object

const LOG_NAME := "ingenitus-chest_qol_mod:ChestHook"
# Access mod_main via load() — a mod's class_name is not in GDScript's global
# registry, so referencing IngenitusChestQolMod here would not compile.
const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-chest_qol_mod/mod_main.gd"
const PASSIVE_RES_PATH := "res://resources/Items/power_ups/PassiveUpgrade.tres"

# generate_chests puts every chest in the middle of a 3x3 "dungeon" whose other
# eight tiles are its protective wall. The ring area covers all nine tiles.
const RING_AREA_NAME := "IngenitusRingArea"
const RING_AREA_SIZE := Vector2(48, 48)
const META_RING := "ingenitus_ring_tiles"
const META_IN_RING := "ingenitus_in_ring"


func _ready(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	var chest := chain.reference_object as Chest
	_cache_ring(chest)
	_add_ring_area(chest)


# Touching the chest itself.
func _on_area_2d_body_entered(chain: ModLoaderHookChain, body: Node2D) -> void:
	chain.execute_next([body])
	var chest := chain.reference_object as Chest
	if not chest.opened and _auto_take(chest) and chest.looted:
		Bus.ShowInputIndicator.emit("interact", false, chest)


# Touching the protective ring. Polled rather than done on entry, because the ring
# can be breached while the player is already standing in it (mining it from the
# inside), which fires no new entry signal.
func _process(chain: ModLoaderHookChain, delta: float) -> void:
	chain.execute_next([delta])
	var chest := chain.reference_object as Chest
	if chest.opened or not chest.get_meta(META_IN_RING, false):
		return
	if not load(MOD_MAIN_PATH).is_on("ring_reach") or not _ring_breached(chest):
		return
	if _auto_take(chest) and chest.in_range and chest.looted:
		Bus.ShowInputIndicator.emit("interact", false, chest)


# A power-up scroll for a weapon no stronger than one of the same kind you already
# own is a dead drop; it becomes a passive-upgrade card (vanilla's multiplier).
func roll_loot(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	if not load(MOD_MAIN_PATH).is_on("skip_weaker_scrolls"):
		return
	var chest := chain.reference_object as Chest
	var loot: Item = chest.loot
	if loot == null or loot.itemType != "scroll" or not loot.itemPickupEffect is PickupTemporaryItem:
		return
	if not _outclassed(loot.itemPickupEffect.item):
		return
	var card: Item = load(PASSIVE_RES_PATH).duplicate(true)
	card.itemPickupEffect.multiplier = float(chest.loot_level) if chest.loot_level <= 4 else float(chest.loot_level ** 2)
	chest.loot = card
	chest.loot_count = 1


# Opens the chest, or with One-Click Looting owned loots it straight to the
# inventory, exactly as pressing interact would. Returns true if it acted.
static func _auto_take(chest: Chest) -> bool:
	var mod_main = load(MOD_MAIN_PATH)
	if not mod_main.is_on("auto_open"):
		return false
	if Gvars.bonus_equipment_manager.auto_loot_chests and mod_main.is_on("auto_grab"):
		chest.auto_loot_chest()
		chest.looted = true
	else:
		chest.openChest()
	chest.opened = true
	return true


static func _cache_ring(chest: Chest) -> void:
	var tiles := PackedInt32Array()
	var chunk := chest.get_parent() as TileMapChunk
	if chunk != null:
		var cell: Vector2i = chunk.local_to_map(chest.position)
		for dx in [-1, 0, 1]:
			for dy in [-1, 0, 1]:
				var n := cell + Vector2i(dx, dy)
				# The 3x3 always fits inside one chunk; a neighbour outside means the
				# chest was not wall-generated, so it has no ring to check.
				if (dx != 0 or dy != 0) and n.x >= 0 and n.y >= 0 and n.x < chunk.chunk_size and n.y < chunk.chunk_size:
					tiles.append(chunk.pos_to_array(n))
	chest.set_meta(META_RING, tiles)


# True once any of the eight protective tiles has been mined out. A chest with no
# recorded ring (hand-placed) counts as breached.
static func _ring_breached(chest: Chest) -> bool:
	var chunk := chest.get_parent() as TileMapChunk
	var ring: PackedInt32Array = chest.get_meta(META_RING, PackedInt32Array())
	if chunk == null or ring.is_empty():
		return true
	for idx in ring:
		if chunk.tiles[idx] == TileMapChunk.Tiles.EMPTY:
			return true
	return false


static func _add_ring_area(chest: Chest) -> void:
	var area := Area2D.new()
	area.name = RING_AREA_NAME
	area.collision_layer = 0
	area.collision_mask = (chest.get_node("Area2D") as Area2D).collision_mask  # the player
	area.monitorable = false
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = RING_AREA_SIZE
	shape.shape = rect
	area.add_child(shape)
	area.body_entered.connect(func(_b: Node2D) -> void: chest.set_meta(META_IN_RING, true))
	area.body_exited.connect(func(_b: Node2D) -> void: chest.set_meta(META_IN_RING, false))
	chest.add_child(area)


static func _outclassed(weapon: Item) -> bool:
	var tier := _tier(weapon)
	if tier < 0:
		return false
	var inventory: Inventory = load("res://resources/Inventories/PlayerInventory.tres")
	for inv_item in inventory.items:
		var owned: Item = inv_item.item if inv_item else null
		if owned != null and owned.itemType == weapon.itemType and _tier(owned) >= tier:
			return true
	return false


# Weapon tier = first number in the resource file name (minigun_08_gold.tres -> 8,
# electric_pickaxe_10_diamond.tres -> 10, poison_staff_2.tres -> 2); itemIDs are
# not consistent (e.g. "GoldElectricPickaxe"). -1 when there is none.
static func _tier(item: Item) -> int:
	for part in item.resource_path.get_file().get_basename().split("_"):
		if part.is_valid_int():
			return int(part)
	return -1
