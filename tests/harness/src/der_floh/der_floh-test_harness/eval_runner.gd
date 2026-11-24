extends RefCounted

const JsonValue := preload("res://mods-unpacked/der_floh-test_harness/json_value.gd")
const INDENT := "\t"
const SNIPPET_HEAD := """extends RefCounted

var tree: SceneTree
var access
var gvars
var bus
var game


func player():
	return access.player()


func tilemap():
	return access.tilemap()


func gui():
	return access.gui()


func mod(mod_id: String):
	return access.mod_main(mod_id)


func run():
"""


func run(code: String, access) -> Dictionary:
	var script := GDScript.new()
	script.source_code = SNIPPET_HEAD + _indent(code)
	var error := script.reload()
	if error != OK:
		return {"ok": false, "error": "The snippet did not compile (%s); the reason is in the test profile's godot.log." % error_string(error)}
	var snippet = script.new()
	snippet.tree = access.tree
	snippet.access = access
	snippet.gvars = access.gvars()
	snippet.bus = access.bus()
	snippet.game = access.game()
	var result = await snippet.run()
	return {"ok": true, "result": JsonValue.convert_value(result)}


static func _indent(code: String) -> String:
	var body := code.strip_edges(false, true)
	if body.is_empty():
		return INDENT + "pass\n"
	var lines := PackedStringArray()
	for line in body.split("\n"):
		lines.append(INDENT + line.trim_suffix("\r"))
	return "\n".join(lines) + "\n"
