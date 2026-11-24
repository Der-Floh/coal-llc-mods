extends RefCounted

## Runs one integration test per call: compiles its file (cached per path and source),
## awaits the test function, then undoes what the test left behind so the next one starts clean.

# Compiled test files take their repo path under res://, so errors in godot.log name the test file.
const VIRTUAL_ROOT := "res://"
const GODOT_LOG := "user://logs/godot.log"
const SCRIPT_ERROR_MARK := "SCRIPT ERROR"
# Scenes a test may open that pause the game or take input focus.
const TRANSIENT_SCENES := ["res://scenes/PauseMenu.tscn", "res://scenes/Interfaces/Menus/Settings2.tscn"]

var _compiled := {}


func run(args: Dictionary, access, commands) -> Dictionary:
	var path := String(args.get("path", ""))
	var function_name := String(args.get("function", ""))
	var log_start := _log_length()
	var script := _compile(path, String(args.get("source", "")))
	if script == null:
		return _result("error", ["%s did not compile." % path] + _new_script_errors(log_start), "", 0)
	var test = script.new()
	if not test.has_method(function_name):
		return _result("error", ["%s has no function %s." % [path, function_name]], "", 0)
	_prepare(test, access, commands)
	var snapshot := _snapshot_configs()
	# Random card offers and rolls repeat from run to run.
	seed(hash(path + function_name))
	var started := Time.get_ticks_msec()
	await test.before_each()
	if test.skip_reason.is_empty() and test.failures.is_empty():
		await Callable(test, function_name).call()
	await test.after_each()
	await test.run_cleanups()
	_restore_configs(snapshot)
	await _close_leftovers(access)
	var errors := _new_script_errors(log_start)
	var messages: Array = test.failures.duplicate()
	messages.append_array(errors)
	return _result(_status(test, errors), messages, test.skip_reason, Time.get_ticks_msec() - started)


func _compile(path: String, source: String) -> GDScript:
	var source_hash := source.hash()
	if _compiled.has(path) and _compiled[path].hash == source_hash:
		return _compiled[path].script
	var script := GDScript.new()
	script.source_code = source
	script.take_over_path(VIRTUAL_ROOT + path)
	if script.reload() != OK:
		_compiled.erase(path)
		return null
	_compiled[path] = {"hash": source_hash, "script": script}
	return script


static func _prepare(test, access, commands) -> void:
	test.tree = access.tree
	test.access = access
	test.commands = commands
	test.gvars = access.gvars()
	test.bus = access.bus()
	test.game = access.game()


# A test's own cleanups restore what it changed through the mods; this also puts back
# config data it changed directly.
static func _snapshot_configs() -> Dictionary:
	var snapshot := {}
	for mod_data in ModLoaderConfig.get_mods_with_config():
		for config in mod_data.configs.values():
			snapshot[config] = var_to_str(config.data)
	return snapshot


static func _restore_configs(snapshot: Dictionary) -> void:
	for config in snapshot:
		if var_to_str(config.data) != snapshot[config]:
			config.data = str_to_var(snapshot[config])
			config.save_to_file()


static func _close_leftovers(access) -> void:
	var tree: SceneTree = access.tree
	for node in tree.root.find_children("*", "", true, false):
		if node.is_queued_for_deletion():
			continue
		if ("choose_between" in node and node.live) or node.scene_file_path in TRANSIENT_SCENES:
			if "live" in node:
				node.live = false
			node.queue_free()
	var gui = access.gui()
	if gui:
		if gui.inventory.visible:
			gui.CloseInventory()
		gui.game_in_focus = true
	_clear_tile_effects(access.tilemap())
	tree.paused = false
	await tree.process_frame
	tree.paused = false


# Poison and fire keep ticking after a test and would damage terrain the next test measures.
static func _clear_tile_effects(tm) -> void:
	if tm == null:
		return
	for chunk in tm.chunks_created.values():
		for idx in chunk.poison_tiles.keys():
			chunk.remove_poison_tile_idx(idx)
		for idx in chunk.burn_tiles.keys():
			chunk.remove_burn_tile_idx(idx)
		for idx in chunk.wet_tiles.keys():
			chunk.remove_wet_tile_idx(idx)


static func _status(test, errors: Array) -> String:
	if not errors.is_empty():
		return "error"
	if not test.skip_reason.is_empty():
		return "skipped"
	return "failed" if not test.failures.is_empty() else "passed"


static func _log_length() -> int:
	var file := FileAccess.open(GODOT_LOG, FileAccess.READ)
	return file.get_length() if file else 0


# A runtime error only ends the test function, so it would pass silently; errors print to godot.log right away.
static func _new_script_errors(from: int) -> Array:
	var file := FileAccess.open(GODOT_LOG, FileAccess.READ)
	if file == null or file.get_length() <= from:
		return []
	file.seek(from)
	var lines := file.get_buffer(file.get_length() - from).get_string_from_utf8().split("\n")
	var errors := []
	for i in lines.size():
		if lines[i].begins_with(SCRIPT_ERROR_MARK):
			var location := lines[i + 1].strip_edges() if i + 1 < lines.size() else ""
			errors.append("%s (%s)" % [lines[i].strip_edges(), location])
	return errors


static func _result(status: String, messages: Array, skip_reason: String, duration_ms: int) -> Dictionary:
	return {"ok": true, "result": {"status": status, "messages": messages, "skip_reason": skip_reason, "duration_ms": duration_ms}}
