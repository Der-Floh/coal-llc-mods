extends "res://resources/passive_effects/passives.gd"


func _get(property: StringName) -> Variant:
	return load("res://mods-unpacked/der_floh-tick_upgrade_mod/mod_main.gd").get_tick_bonus(String(property))


func save() -> Dictionary:
	var part: Dictionary = super.save()
	var mod_main = load("res://mods-unpacked/der_floh-tick_upgrade_mod/mod_main.gd")
	part[mod_main.SAVE_KEY] = mod_main.save_data()
	return part


func load_save(_save: Dictionary):
	super.load_save(_save)
	var mod_main = load("res://mods-unpacked/der_floh-tick_upgrade_mod/mod_main.gd")
	mod_main.load_data(_save.get(mod_main.SAVE_KEY))


func reset():
	super.reset()
	load("res://mods-unpacked/der_floh-tick_upgrade_mod/mod_main.gd").reset_tick_speeds()
