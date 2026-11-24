extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Every ore's sell price is its vanilla price times its multiplier (1 by default), Mod Enabled
# off gives vanilla prices, and Coal Is Worthless still makes coal worthless.

const MOD_ID := "der_floh-ore_value_mod"
const VANILLA_PRICES := {
	"Coal": 1.0, "CopperOre": 3.0, "IronOre": 4.0, "SilverOre": 40.0, "GoldOre": 300.0,
	"Amethyst": 70.0, "Sapphire": 8.0, "Emerald": 10.0, "Ruby": 500.0, "Diamond": 4000.0,
	"PinkDiamond": 7500.0, "spinel": 7.5e5, "uranium": 7.5e9, "moonstone": 3.75e14, "onyx": 7.5e18,
}
const COAL_IS_WORTHLESS := "res://resources/hard_modifiers/1_coal_is_worthless.tres"
const SPINEL := "res://resources/Items/Gems/Spinel.tres"


func before_each() -> void:
	if await in_management():
		on_cleanup(_reset_multipliers)


func test_default_multipliers_keep_vanilla_prices() -> void:
	for id in VANILLA_PRICES:
		expect_eq(mod(MOD_ID).get_multiplier(id), 1.0, "%s multiplier" % id)
		expect_eq(_price(id), VANILLA_PRICES[id], "%s price" % id)


func test_multipliers_scale_prices() -> void:
	var ore_value = mod(MOD_ID)
	var multipliers := {"Coal": 1000000.0, "GoldOre": 0.0, "IronOre": 0.5, "spinel": 10.0, "onyx": 2.0}
	for id in multipliers:
		ore_value.set_multiplier(id, multipliers[id])
	ore_value.apply_prices()
	for id in multipliers:
		expect_eq(_price(id), VANILLA_PRICES[id] * multipliers[id], "%s price at ×%s" % [id, multipliers[id]])
	use_setting(MOD_ID, "enabled", false)
	ore_value.apply_prices()
	for id in multipliers:
		expect_eq(_price(id), VANILLA_PRICES[id], "%s price with the mod disabled" % id)


func test_number_boxes_apply_at_once() -> void:
	var menu = await open_settings()
	var rows := {}
	for row in menu.tab_container.get_node("Ore Value").find_children("*", "HBoxContainer", true, false):
		if row.get_child_count() > 1 and row.get_child(1) is Range:
			rows[row.get_child(0).text] = row.get_child(1)
	expect_eq(rows.size(), VANILLA_PRICES.size(), "one number box per ore")
	var gold = rows.get("Gold Ore")
	if not expect(gold != null, "a Gold Ore box"):
		return
	expect_eq([gold.min_value, gold.max_value, gold.step], [0.0, 1e15, 1.0], "[min, max, step]")
	gold.value = 7
	expect_eq(_price("GoldOre"), 2100.0, "Gold Ore price right after typing 7")


func test_coal_is_worthless_wins() -> void:
	var ore_value = mod(MOD_ID)
	ore_value.set_multiplier("Coal", 1000.0)
	use_value(gvars, "hard_modifier", load(COAL_IS_WORTHLESS))
	gvars.reset_resources()
	expect_eq(_price("Coal"), 0.0, "coal under Coal Is Worthless")
	on_cleanup(func() -> void: gvars.reset_resources())


func test_prices_last_through_a_day() -> void:
	mod(MOD_ID).set_multiplier("spinel", 10.0)
	mod(MOD_ID).apply_prices()
	if not await give(SPINEL) or not await in_mine():
		return
	expect_eq(_price("spinel"), 7.5e6, "spinel price after the day started")
	var held := (gvars.playerInventory.items as Array).filter(func(slot) -> bool: return slot.item and slot.item.resource_path == SPINEL)
	if expect(not held.is_empty(), "the spinel is in the inventory"):
		expect_eq(held[0].item.itemSellPrice, 7.5e6, "the inventory's spinel has the new price")


func _price(id: String) -> float:
	return load(mod(MOD_ID).ITEM_PATHS[id]).itemSellPrice


func _reset_multipliers() -> void:
	var ore_value = mod(MOD_ID)
	for id in VANILLA_PRICES:
		ore_value.set_multiplier(id, 1.0)
	ore_value.apply_prices()
