extends RefCounted

const GameAccess := preload("res://mods-unpacked/der_floh-test_harness/game_access.gd")
const EvalRunner := preload("res://mods-unpacked/der_floh-test_harness/eval_runner.gd")
const TestRunner := preload("res://mods-unpacked/der_floh-test_harness/test_runner.gd")
const CHOOSE_PASSIVE_SCRIPT := "res://scenes/Interfaces/in_game/choose_passive.gd"
const PROFESSION_PATH := "res://resources/professions/%s.tres"
const DEFAULT_RUN := {"profession": "generalist", "level": "STANDARD", "mode": "PEACEFUL"}
const STAGE_ENTRY_POSITION := Vector2(51, -80)
const STAGE_TIMEOUT_MS := 30000
const CHOOSER_TIMEOUT_MS := 5000
const PICK_METHODS := ["_on_button_pressed", "_on_button_2_pressed", "_on_button_3_pressed"]
const TILE_EFFECTS := ["poison", "burn", "wet"]
const ACTION_MODES := ["tap", "press", "release"]
const EMPTY_ITEM_TYPE := "empty"
const EMPLOYEE_ICON_GROUP := &"employee_icons"

var _access: GameAccess
var _eval_runner := EvalRunner.new()
var _test_runner := TestRunner.new()
var _screenshot_dir: String
var _handlers: Dictionary


func _init(access: GameAccess, screenshot_dir: String) -> void:
	_access = access
	_screenshot_dir = screenshot_dir
	_handlers = {
		"status": status,
		"eval": eval_code,
		"run_test": run_test,
		"screenshot": screenshot,
		"quit": quit,
		"new_run": new_run,
		"continue_run": continue_run,
		"start_day": start_day,
		"end_day": end_day,
		"finish_day": finish_day,
		"set_seconds_left": set_seconds_left,
		"give_item": give_item,
		"set_cash": set_cash,
		"set_vacuum": set_vacuum,
		"add_passive": add_passive,
		"open_chooser": open_chooser,
		"pick": pick,
		"teleport": teleport,
		"tile_effect": tile_effect,
		"action": action,
		"inventory": inventory,
	}


func handle(_method: String, path: String, args: Dictionary) -> Dictionary:
	var command := path.trim_prefix("/")
	if not _handlers.has(command):
		return _fail("Unknown command '%s'. Known: %s." % [command, ", ".join(PackedStringArray(_handlers.keys()))])
	return await _handlers[command].call(args)


# --- Harness ---

func status(_args: Dictionary) -> Dictionary:
	var gvars := _access.gvars()
	var current := _access.stage()
	return _ok({
		"pid": OS.get_process_id(),
		"user_data_dir": OS.get_user_data_dir(),
		"stage": String(current.name) if current else "",
		"transitioning": _access.is_transitioning(),
		"management_screen": _access.management_screen() != null,
		"paused": _access.tree.paused,
		"day": gvars.dayCount,
		"days_passed": gvars.daysPassed,
		"seconds_left": gvars.secondsLeft,
		"cash": gvars.CashCount,
		"profession": gvars.profession.profession_name if gvars.profession else "",
		"vacuum": gvars.bonus_equipment_manager.current_vacuum,
		"inventory": _inventory_state(gvars.playerInventory),
		"passives": _passive_values(gvars),
		"chooser": _chooser_state(),
		"mods": _mod_list(),
	})


func eval_code(args: Dictionary) -> Dictionary:
	return await _eval_runner.run(String(args.get("code", "")), _access)


func run_test(args: Dictionary) -> Dictionary:
	return await _test_runner.run(args, _access, self)


func screenshot(args: Dictionary) -> Dictionary:
	var path := _screenshot_dir.path_join(String(args.get("name", "screenshot")).validate_filename() + ".png")
	DirAccess.make_dir_recursive_absolute(_screenshot_dir)
	await RenderingServer.frame_post_draw
	var error := _access.tree.root.get_texture().get_image().save_png(path)
	if error != OK:
		return _fail("Saving %s failed (%s)." % [path, error_string(error)])
	return _ok({"path": path})


func quit(_args: Dictionary) -> Dictionary:
	_access.tree.quit.call_deferred()
	return _ok()


# --- Run and day flow ---

func new_run(args: Dictionary) -> Dictionary:
	var settings := DEFAULT_RUN.merged(args, true)
	var gconsts := _access.gconsts()
	var profession_path := PROFESSION_PATH % settings["profession"]
	var profession = load(profession_path) if ResourceLoader.exists(profession_path) else null
	var level = gconsts.Level.get(String(settings["level"]).to_upper())
	var mode = gconsts.Mode.get(String(settings["mode"]).to_upper())
	if profession == null or level == null or mode == null:
		return _fail("Unknown profession, level or mode in %s." % settings)
	var gvars := _access.gvars()
	var hard_modifier = gvars.hard_modifier_manager.enum_to_resource(gconsts.HardModifiers.NONE)
	gvars.reset_game(level, profession, mode, hard_modifier)
	return await _open_management_screen()


func continue_run(_args: Dictionary) -> Dictionary:
	var gvars := _access.gvars()
	gvars.reset_game()
	gvars.load_game()
	return await _open_management_screen()


func start_day(_args: Dictionary) -> Dictionary:
	if _access.management_screen() == null:
		return _fail("start_day needs the management screen; use new_run or continue_run first.")
	_access.stage().on_closeManagementScreen()
	if not await _access.wait_until(func() -> bool: return _access.mine() != null, STAGE_TIMEOUT_MS):
		return _fail("The mine did not finish loading in time.")
	return await status({})


func end_day(args: Dictionary) -> Dictionary:
	if _access.mine() == null:
		return _fail("end_day needs a running mine day.")
	var skip_summary := bool(args.get("skip_summary", true))
	var gvars := _access.gvars()
	if skip_summary:
		gvars.daysPassed = gvars.dayCount
	_access.bus().emit_signal("EndDay")
	var arrived := func() -> bool: return _access.management_screen() != null if skip_summary else _left_mine()
	if not await _access.wait_until(arrived, STAGE_TIMEOUT_MS):
		return _fail("The end of the day did not finish in time.")
	return await status({})


func finish_day(_args: Dictionary) -> Dictionary:
	var stage := _access.stage()
	var summary = stage.get("profit_instance") if stage else null
	if summary == null or not is_instance_valid(summary):
		return _fail("finish_day needs the profit summary; use end_day with skip_summary false first.")
	if not await _access.wait_until(func() -> bool: return not summary.continue_button.disabled, STAGE_TIMEOUT_MS):
		return _fail("The profit summary did not finish counting in time.")
	summary._on_continue_button_pressed()
	if not await _access.wait_until(func() -> bool: return _access.management_screen() != null, STAGE_TIMEOUT_MS):
		return _fail("The management screen did not open in time; a missed quota ends the run instead.")
	return await status({})


func set_seconds_left(args: Dictionary) -> Dictionary:
	var seconds := maxi(0, int(args.get("seconds", 0)))
	_access.gvars().secondsLeft = seconds
	return _ok({"seconds_left": seconds})


# --- Cheats ---

func give_item(args: Dictionary) -> Dictionary:
	var path := String(args.get("path", ""))
	var item = load(path) if ResourceLoader.exists(path) else null
	if item == null or item.get("itemType") == null:
		return _fail("'%s' is not an item resource." % path)
	var added = _access.gvars().playerInventory.addToInventory(item, float(args.get("count", 1)))
	return _ok({"added": added})


func set_cash(args: Dictionary) -> Dictionary:
	var gvars := _access.gvars()
	gvars.CashCount = float(args.get("amount", 0))
	_access.bus().emit_signal("UpdateUI")
	return _ok({"cash": gvars.CashCount})


func set_vacuum(args: Dictionary) -> Dictionary:
	var level := int(args.get("level", 1))
	_access.gvars().bonus_equipment_manager.current_vacuum = level
	var manager := _access.equipment_manager()
	if manager:
		_remove_vacuums(manager)
		manager.generate_vacuum_cleaner()
	return _ok({"vacuum": level, "rebuilt_in_mine": manager != null})


func add_passive(args: Dictionary) -> Dictionary:
	var key := String(args.get("key", ""))
	var passives = _access.gvars().passives
	var before = passives.get(key)
	if before == null:
		return _fail("'%s' is not a passive the game or a loaded mod exposes." % key)
	passives.apply_effect(key, float(args.get("amount", 0.05)))
	if passives.get(key) == before:
		return _fail("'%s' did not change; the mod that owns it doesn't apply it through Passives, so use eval." % key)
	return _ok({key: passives.get(key)})


# --- Level-up cards ---

func open_chooser(args: Dictionary) -> Dictionary:
	if _access.mine() == null:
		return _fail("Level-up cards only open during a mine day.")
	_access.bus().emit_signal("choose_passive", float(args.get("multiplier", 1.0)))
	if not await _access.wait_until(func() -> bool: return _access.chooser() != null, CHOOSER_TIMEOUT_MS):
		return _fail("No level-up card appeared.")
	return _ok(_chooser_state())


func pick(args: Dictionary) -> Dictionary:
	var chooser := _access.chooser()
	if chooser == null:
		return _fail("No level-up card is open.")
	var index := int(args.get("index", 0))
	if index < 0 or index >= PICK_METHODS.size():
		return _fail("index must be 0, 1 or 2.")
	var key: String = chooser.choose_between[index]
	chooser.call(PICK_METHODS[index])
	await _access.tree.process_frame
	return _ok({"picked": key, "value": _access.gvars().passives.get(key)})


# --- World and input ---

func teleport(args: Dictionary) -> Dictionary:
	var player := _access.player()
	if player == null:
		return _fail("teleport needs a mine day.")
	var target := Vector2(float(args.get("x", 0)), float(args.get("y", 0)))
	_access.tilemap().generate_chunks(target)
	player.global_position = target
	return _ok({"position": target})


func tile_effect(args: Dictionary) -> Dictionary:
	var tilemap := _access.tilemap()
	var kind := String(args.get("kind", "poison"))
	if tilemap == null or kind not in TILE_EFFECTS:
		return _fail("tile_effect needs a mine day and a kind of poison, burn or wet.")
	var target := Vector2(float(args.get("x", 0)), float(args.get("y", 0)))
	var damage := float(args.get("damage", 10))
	var ticks := int(args.get("ticks", 10))
	match kind:
		"poison":
			tilemap.poison_tile(target, damage, ticks)
		"burn":
			tilemap.burn_tile(target, damage, ticks)
		"wet":
			tilemap.wet_tile(target)
	return _ok()


func action(args: Dictionary) -> Dictionary:
	var action_name := String(args.get("name", ""))
	var mode := String(args.get("mode", "tap"))
	if not InputMap.has_action(action_name) or mode not in ACTION_MODES:
		return _fail("Unknown input action '%s' or mode '%s' (tap, press, release)." % [action_name, mode])
	if mode != "release":
		_send_action(action_name, true)
	if mode == "tap":
		await _access.tree.physics_frame
		await _access.tree.physics_frame
	if mode != "press":
		_send_action(action_name, false)
	return _ok()


func inventory(args: Dictionary) -> Dictionary:
	var gui := _access.gui()
	if gui == null:
		return _fail("The inventory window only exists during a mine day.")
	if bool(args.get("open", true)):
		gui.OpenInventory()
	else:
		gui.CloseInventory()
	await _access.tree.process_frame
	return _ok()


# --- Helpers ---

func _open_management_screen() -> Dictionary:
	_forget_employee_icons()
	_access.game().change_stage(_access.gconsts().Stages._END_OF_DAY_OVERLAY, STAGE_ENTRY_POSITION)
	if not await _access.wait_until(func() -> bool: return _access.management_screen() != null, STAGE_TIMEOUT_MS):
		return _fail("The management screen did not open in time.")
	return await status({})


# change_stage builds the new stage while the old one is only queued for deletion, and a new management
# screen's chart registers every icon in this group, so it would keep drawing the old screen's freed icons.
func _forget_employee_icons() -> void:
	for icon in _access.tree.get_nodes_in_group(EMPLOYEE_ICON_GROUP):
		icon.remove_from_group(EMPLOYEE_ICON_GROUP)


func _left_mine() -> bool:
	return _access.stage() != null and not _access.is_transitioning() and _access.mine() == null


func _passive_values(gvars: Node) -> Dictionary:
	var passives = gvars.passives
	var values := {}
	for key in _passive_keys(gvars):
		var value = passives.get(key)
		if value is float and value != 0.0:
			values[key] = value
	return values


static func _passive_keys(gvars: Node) -> Array:
	var keys: Array = load(CHOOSE_PASSIVE_SCRIPT).ALL_PASSIVES.keys()
	if gvars.profession:
		for key in gvars.profession._profession_effect({"unlocked_passives": []})["unlocked_passives"]:
			if key not in keys:
				keys.append(key)
	return keys


func _chooser_state() -> Variant:
	var chooser := _access.chooser()
	if chooser == null:
		return null
	return {
		"options": chooser.choose_between,
		"multiplier": chooser.multiplier,
		"labels": [chooser.button.text, chooser.button_2.text, chooser.button_3.text],
	}


func _mod_list() -> Array:
	var mods := []
	var mod_data: Dictionary = _access.autoload("ModLoaderStore").mod_data
	for dir_name in mod_data:
		var data = mod_data[dir_name]
		mods.append({"id": dir_name, "version": data.manifest.version_number if data.manifest else "", "active": data.is_active})
	return mods


static func _inventory_state(player_inventory: Object) -> Dictionary:
	var items := []
	for slot in player_inventory.items:
		var item_type = slot.item.get("itemType") if slot.item else null
		if item_type != EMPTY_ITEM_TYPE:
			items.append({"type": item_type, "path": slot.item.resource_path if slot.item else "", "count": slot.count})
	return {"slots": player_inventory.items.size(), "max_slots": player_inventory.maxSlots, "items": items}


static func _remove_vacuums(manager: Node) -> void:
	for child in manager.get_children():
		if "vacuum_length" in child:
			manager.remove_child(child)
			child.queue_free()


static func _send_action(action_name: String, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action_name
	event.pressed = pressed
	Input.parse_input_event(event)


static func _ok(result: Variant = null) -> Dictionary:
	return {"ok": true, "result": result}


static func _fail(message: String) -> Dictionary:
	return {"ok": false, "error": message}
