extends RefCounted

## Base class of the integration tests in tests/integration/. Every func test_*() of a
## file extending this one runs inside the game, awaited, with the helpers below.
## Failed expectations are collected instead of stopping the test, and everything
## registered with on_cleanup() is undone after it, whatever happened.

const DEFAULT_PROFESSION := "generalist"
const DEFAULT_MODE := "PEACEFUL"
const DEFAULT_LEVEL := "STANDARD"
# Long enough that no test sees its mine day end.
const LONG_DAY_SECONDS := 3600
const KEY_HOLD_FRAMES := 2
const SETTINGS_SCENE := "res://scenes/Interfaces/Menus/Settings2.tscn"

var tree: SceneTree
var access
var commands
var gvars
var bus
var game

var failures: Array[String] = []
var skip_reason := ""
var _cleanups: Array[Callable] = []


## Runs before every test of the file; override it, it may await.
func before_each() -> void:
	pass


## Runs after every test of the file, before the registered cleanups; override it, it may await.
func after_each() -> void:
	pass


# --- Game access ---

func player():
	return access.player()


func tilemap():
	return access.tilemap()


func gui():
	return access.gui()


## The mod_main script of a loaded mod, whose static functions and settings tests call.
func mod(mod_id: String):
	return access.mod_main(mod_id)


func has_mod(mod_id: String) -> bool:
	return ModLoaderMod.is_mod_active(mod_id)


func frames(count := 1) -> void:
	for i in count:
		await tree.process_frame


func physics_frames(count := 1) -> void:
	for i in count:
		await tree.physics_frame


# --- Fixtures ---

## Starts a new run and waits for the management screen.
func fresh_run(profession := DEFAULT_PROFESSION, mode := DEFAULT_MODE, level := DEFAULT_LEVEL) -> bool:
	return _succeeded(await commands.new_run({"profession": profession, "mode": mode, "level": level}))


## The management screen of the current run, or of a new run when there is none.
func in_management() -> bool:
	if access.management_screen() != null:
		return true
	if access.mine() != null:
		return _succeeded(await commands.end_day({}))
	return await fresh_run()


## A mine day of the current run, started if needed, with a day long enough for any test.
func in_mine() -> bool:
	if access.mine() == null:
		if not await in_management():
			return false
		if not _succeeded(await commands.start_day({})):
			return false
	gvars.secondsLeft = LONG_DAY_SECONDS
	return true


## A new run's first mine day, for tests that need untouched terrain or inventory.
func fresh_mine(profession := DEFAULT_PROFESSION, mode := DEFAULT_MODE, level := DEFAULT_LEVEL) -> bool:
	if not await fresh_run(profession, mode, level):
		return false
	return await in_mine()


func give(item_path: String, count := 1) -> bool:
	return _succeeded(await commands.give_item({"path": item_path, "count": count}))


func set_vacuum(level: int) -> bool:
	return _succeeded(await commands.set_vacuum({"level": level}))


## Presses and releases a key; _shortcut_input only sees key events with both key codes set.
func press_key(keycode: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = keycode
		event.physical_keycode = keycode
		event.pressed = pressed
		Input.parse_input_event(event)
		await physics_frames(KEY_HOLD_FRAMES)


# --- Settings menu ---

## Opens the game's settings menu with every mod tab; it is closed after the test.
func open_settings():
	var menu = load(SETTINGS_SCENE).instantiate()
	tree.root.add_child(menu)
	await frames()
	on_cleanup(func() -> void:
		if is_instance_valid(menu):
			menu.queue_free())
	return menu


## The switches and sliders of one settings tab, by label: a switch's state, or a slider's
## [min, max, step, value, default].
func settings_rows(menu, tab_name: String) -> Dictionary:
	var tab = menu.tab_container.get_node_or_null(tab_name)
	if tab == null:
		fail("no settings tab named " + tab_name)
		return {}
	var rows := {}
	for control in tab.find_children("*", "", true, false):
		if control is SettingBool:
			rows[control.setting_label.text] = control.check_button.button_pressed
		elif control is SettingSlider:
			rows[control.setting_label.text] = [control.slider.min_value, control.slider.max_value, control.slider.step, control.slider.value, control.default]
	return rows


## The setting control of a tab whose label starts with this text.
func setting_control(menu, tab_name: String, label_start: String):
	for control in menu.tab_container.get_node(tab_name).find_children("*", "", true, false):
		if (control is SettingBool or control is SettingSlider) and control.setting_label.text.begins_with(label_start):
			return control
	fail("%s has no setting starting with '%s'" % [tab_name, label_start])
	return null


# --- Settings with automatic restore ---

func on_cleanup(restore: Callable) -> void:
	_cleanups.append(restore)


## Sets a mod setting through its set_<setting>() and restores get_<setting>()'s value after the test.
func use_setting(mod_id: String, setting: String, value) -> void:
	var mod_main = mod(mod_id)
	var previous = mod_main.call("get_" + setting)
	mod_main.call("set_" + setting, value)
	on_cleanup(func() -> void: mod_main.call("set_" + setting, previous))


## Sets a property and restores its previous value after the test.
func use_value(target: Object, property: String, value) -> void:
	var previous = target.get(property)
	target.set(property, value)
	on_cleanup(func() -> void: target.set(property, previous))


# --- Expectations ---

func expect(condition: bool, message: String) -> bool:
	if not condition:
		failures.append(message)
	return condition


func expect_eq(actual, expected, message := "") -> bool:
	return expect(_same(actual, expected), "%sexpected %s, got %s" % [_prefix(message), _show(expected), _show(actual)])


func expect_near(actual: float, expected: float, tolerance: float, message := "") -> bool:
	return expect(absf(actual - expected) <= tolerance, "%sexpected %s ± %s, got %s" % [_prefix(message), expected, tolerance, actual])


func expect_between(actual: float, low: float, high: float, message := "") -> bool:
	return expect(actual >= low and actual <= high, "%sexpected %s to %s, got %s" % [_prefix(message), low, high, actual])


func fail(message: String) -> void:
	failures.append(message)


## Marks the test as skipped; return right after calling it.
func skip(reason: String) -> void:
	skip_reason = reason


## Skips the test unless all these mods are loaded; use as: if not require_mods([...]): return
func require_mods(mod_ids: Array) -> bool:
	var missing := mod_ids.filter(func(mod_id) -> bool: return not has_mod(mod_id))
	if not missing.is_empty():
		skip("needs " + ", ".join(PackedStringArray(missing)))
	return missing.is_empty()


# --- Used by test_runner.gd ---

func run_cleanups() -> void:
	while not _cleanups.is_empty():
		await _cleanups.pop_back().call()


func _succeeded(response: Dictionary) -> bool:
	if not response.get("ok", false):
		fail(String(response.get("error", "the harness command failed")))
		return false
	return true


static func _prefix(message: String) -> String:
	return message + ": " if not message.is_empty() else ""


static func _show(value) -> String:
	return var_to_str(value).replace("\n", " ")


# == errors in GDScript when the types can't be compared, so numbers compare by value
# and containers element by element.
static func _same(actual, expected) -> bool:
	if _is_number(actual) and _is_number(expected):
		return is_equal_approx(float(actual), float(expected))
	if typeof(actual) != typeof(expected):
		return false
	if actual is Array:
		return actual.size() == expected.size() and range(actual.size()).all(func(i: int) -> bool: return _same(actual[i], expected[i]))
	if actual is Dictionary:
		return actual.size() == expected.size() and actual.keys().all(func(key) -> bool: return expected.has(key) and _same(actual[key], expected[key]))
	return actual == expected


static func _is_number(value) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT]
