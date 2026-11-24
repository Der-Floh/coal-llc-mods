extends RefCounted

const MINE_STAGE := "MineRegion"
const GUI_NODE := "GUICanvasLayer"
const PLAYER_NODE := "Player"
const TILEMAP_NODE := "TileMapManager"
const EQUIPMENT_MANAGER_NODE := "EquipmentManager"
const MANAGEMENT_PROPERTY := "management_instance"
const MOD_MAIN_PATH := "res://mods-unpacked/%s/mod_main.gd"

var tree: SceneTree


func _init(scene_tree: SceneTree) -> void:
	tree = scene_tree


func autoload(autoload_name: String) -> Node:
	return tree.root.get_node_or_null(NodePath(autoload_name))


func gvars() -> Node:
	return autoload("Gvars")


func bus() -> Node:
	return autoload("Bus")


func game() -> Node:
	return autoload("Game")


func gconsts() -> Node:
	return autoload("Gconsts")


func mod_main(mod_id: String) -> Script:
	var path := MOD_MAIN_PATH % mod_id
	return load(path) if ResourceLoader.exists(path) else null


func stage() -> Node:
	var current = game().current_node
	return current if is_instance_valid(current) else null


func is_transitioning() -> bool:
	return game().visible


func mine() -> Node:
	var current := stage()
	if current and current.name == MINE_STAGE and not is_transitioning():
		return current
	return null


func management_screen() -> Node:
	var current := stage()
	if current == null or is_transitioning():
		return null
	var screen = current.get(MANAGEMENT_PROPERTY)
	return screen if is_instance_valid(screen) else null


func player() -> Node:
	return _mine_child(PLAYER_NODE)


func tilemap() -> Node:
	return _mine_child(TILEMAP_NODE)


func gui() -> Node:
	return _mine_child(GUI_NODE)


func equipment_manager() -> Node:
	return _mine_child(EQUIPMENT_MANAGER_NODE)


func chooser() -> Node:
	var layer := gui()
	if layer == null:
		return null
	for child in layer.get_children():
		if "choose_between" in child and child.live:
			return child
	return null


func wait_until(condition: Callable, timeout_ms: int) -> bool:
	var deadline := Time.get_ticks_msec() + timeout_ms
	while not condition.call():
		if Time.get_ticks_msec() > deadline:
			return false
		await tree.process_frame
	return true


func _mine_child(node_name: String) -> Node:
	var current := mine()
	return current.get_node_or_null(NodePath(node_name)) if current else null
