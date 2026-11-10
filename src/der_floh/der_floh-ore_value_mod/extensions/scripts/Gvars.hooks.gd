extends Object

const MOD_MAIN_PATH := "res://mods-unpacked/der_floh-ore_value_mod/mod_main.gd"


func reset_resources(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	load(MOD_MAIN_PATH).apply_prices()
