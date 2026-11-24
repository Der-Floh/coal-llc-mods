extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Runs first in every session, whatever mods it loads.

const SCRIPT_ERROR_MARK := "SCRIPT ERROR"
const GODOT_LOG := "user://logs/godot.log"
const INVENTORY_PATH := "res://resources/Inventories/PlayerInventory.tres"
const EMPTY_ITEM_PATH := "res://resources/Items/Empty.tres"
const INVENTORY_SLOTS := 10


func test_game_started_without_script_errors() -> void:
	var startup_log := FileAccess.get_file_as_string(GODOT_LOG)
	expect_eq(startup_log.count(SCRIPT_ERROR_MARK), 0, "SCRIPT ERROR lines in godot.log since the game started")


# Loading game scripts too early leaves Empty.tres without its Item script, and the inventory shrinks to the pickaxe slot.
func test_inventory_keeps_all_slots() -> void:
	if not await fresh_run():
		return
	expect_eq(load(INVENTORY_PATH).items.size(), INVENTORY_SLOTS, "inventory slots in a new run")
	expect(load(EMPTY_ITEM_PATH).get_script() != null, "Empty.tres keeps its Item script")


func test_settings_menu_opens() -> void:
	var menu = load(SETTINGS_SCENE).instantiate()
	tree.root.add_child(menu)
	await frames()
	expect(menu.tab_container.get_tab_count() > 0, "the settings menu has tabs")
	menu.queue_free()


func test_a_day_starts_and_ends() -> void:
	if not await fresh_mine():
		return
	expect(access.mine() != null, "the mine loaded")
	expect(await in_management(), "the day ended back on the management screen")
