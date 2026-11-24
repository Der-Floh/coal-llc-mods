extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# A passive is only offered while an item it applies to (or a vacuum) is owned, and leaves the pool at its cap.

const MOD_ID := "ingenitus-extra_passives_mod"
const EQUIPMENT := "res://resources/Items/Equipment/"
const PISTOL := "Guns/pistols/pistol_01_shoddy.tres"
const INDUCER := "earthquake_inducers/earthquake_inducer_01.tres"
const DYNAMITE := "Bombs/weak_dynamite.tres"
const GUN_PASSIVES := ["gun_fire_rate", "multi_projectile", "bullet_pierce"]
# Rifles and miniguns already fire below Gun Fire Rate's cooldown floor, so it isn't offered for them.
const FAST_GUN_PASSIVES := ["multi_projectile", "bullet_pierce"]
const ITEM_OFFERS := {
	PISTOL: GUN_PASSIVES,
	"Guns/shotguns/shotgun_01_shoddy.tres": GUN_PASSIVES,
	"Guns/rifles/rifle_01_shoddy.tres": FAST_GUN_PASSIVES,
	"Guns/miniguns/minigun_01_shoddy.tres": FAST_GUN_PASSIVES,
	"axes/axe_01_shoddy.tres": ["axe_spin_speed"],
	"battleaxes/battleaxe_01_shoddy.tres": ["axe_spin_speed"],
	"structures/drills/drill_01.tres": ["drill_mining_speed"],
	INDUCER: ["earthquake_damage", "earthquake_radius"],
	DYNAMITE: ["bomb_radius"],
	"Bombs/tactical_nuke.tres": ["bomb_radius"],
}
const CAPPED := ["gun_fire_rate", "earthquake_radius", "bomb_radius"]


func before_each() -> void:
	if await fresh_run():
		mod(MOD_ID).reset_passives()


func test_nothing_is_offered_with_only_the_pickaxe() -> void:
	expect_eq(_offered(), [], "offers")


func test_each_item_offers_its_passives() -> void:
	var inventory = gvars.playerInventory
	for path in ITEM_OFFERS:
		var item = load(EQUIPMENT + path)
		inventory.addToInventory(item, 1)
		expect_eq(_offered(), ITEM_OFFERS[path], path)
		inventory.sellFromInventory(item, 1)


func test_vacuum_passives_need_a_vacuum() -> void:
	if not await set_vacuum(1):
		return
	expect_eq(_offered(), ["vacuum_range", "vacuum_power"], "offers with a vacuum")


func test_capped_passives_leave_the_pool() -> void:
	var extra_passives = mod(MOD_ID)
	for path in [PISTOL, INDUCER, DYNAMITE]:
		gvars.playerInventory.addToInventory(load(EQUIPMENT + path), 1)
	for levels in [[12.95, 3.75, 10.95], [13.0, 3.8, 11.0]]:
		for i in CAPPED.size():
			extra_passives.set_passive(CAPPED[i], levels[i])
		var below_cap: bool = levels[0] < 13.0
		for key in CAPPED:
			expect_eq(extra_passives.offerable(key), below_cap, "%s offerable at %s" % [key, extra_passives.level(key)])
		expect(extra_passives.offerable("multi_projectile"), "uncapped multi_projectile stays offerable")


func _offered() -> Array:
	var extra_passives = mod(MOD_ID)
	extra_passives.building_offer = true
	var pool: Array = gvars.profession._profession_effect({"unlocked_passives": []})["unlocked_passives"]
	extra_passives.building_offer = false
	return extra_passives.PASSIVES.keys().filter(func(key) -> bool: return pool.has(key))
