extends "res://resources/passive_effects/passives.gd"

# Godot 4.4 can't compile a second script extension of a class_name script, so every mod that adds passives
# ships this same file, only the first one installs it, and each registers its mod_main as a provider.
const PROVIDERS_META := &"coal_llc_passive_providers"


static func _providers() -> Array:
	return Engine.get_meta(PROVIDERS_META, [])


func _get(property: StringName) -> Variant:
	for provider in _providers():
		var value = provider.get_passive(String(property))
		if value != null:
			return value
	return null


func _set(property: StringName, value: Variant) -> bool:
	for provider in _providers():
		if provider.set_passive(String(property), value):
			return true
	return false


func save() -> Dictionary:
	var part: Dictionary = super.save()
	for provider in _providers():
		provider.save_passives(part)
	return part


func load_save(_save: Dictionary):
	super.load_save(_save)
	for provider in _providers():
		provider.load_passives(_save)


func reset():
	super.reset()
	for provider in _providers():
		provider.reset_passives()
