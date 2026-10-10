extends "res://resources/passive_effects/passives.gd"

# The new passives are not properties of Passives, so their levels live in
# mod_main. _get/_set expose them as if they were: vanilla apply_effect
# (set(name, get(name) + amount)), NanobotZ-AutoPassiveChooser's "up to" limits
# (Gvars.passives.get(effect)) and any other code reading passives by name see
# the real values. They are saved inside the run save under their own key.

const _MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-extra_passives_mod/mod_main.gd"


func _get(property: StringName) -> Variant:
	var mod_main = load(_MOD_MAIN_PATH)
	if mod_main.PASSIVES.has(String(property)):
		return float(mod_main.levels.get(String(property), 0.0))
	return null


func _set(property: StringName, value: Variant) -> bool:
	var mod_main = load(_MOD_MAIN_PATH)
	var key := String(property)
	if not mod_main.PASSIVES.has(key):
		return false
	mod_main.add_level(key, float(value) - float(mod_main.levels.get(key, 0.0)))
	return true


func save() -> Dictionary:
	var part: Dictionary = super.save()
	var mod_main = load(_MOD_MAIN_PATH)
	part[mod_main.SAVE_KEY] = mod_main.save_data()
	return part


func load_save(_save: Dictionary):
	super.load_save(_save)
	var mod_main = load(_MOD_MAIN_PATH)
	mod_main.load_data(_save.get(mod_main.SAVE_KEY, {}))


func reset():
	super.reset()
	load(_MOD_MAIN_PATH).reset_levels()
