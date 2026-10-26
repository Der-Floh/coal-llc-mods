extends "res://scripts/Gvars.gd"


func reset_resources() -> void:
	super.reset_resources()
	load("res://mods-unpacked/der_floh-ore_value_mod/mod_main.gd").apply_prices()
