extends "res://scripts/Gvars.gd"

const LOG_NAME := "der_floh-ore_value_mod:Gvars"


func reset_resources() -> void:
	super.reset_resources()

	var mod_main := load("res://mods-unpacked/der_floh-ore_value_mod/mod_main.gd")
	for _sellable in all_sellables:
		var multiplier: float = mod_main.get_multiplier(_sellable.itemID)
		if multiplier == 1.0:
			continue  # at vanilla value — skip the reload entirely

		# CACHE_MODE_REPLACE forces a fresh Resource instance so each save
		# gets its own copy — without it the multiplier would compound across saves.
		var item = ResourceLoader.load(
			_sellable.resource_path, "", ResourceLoader.CacheMode.CACHE_MODE_REPLACE
		)
		item.itemSellPrice *= multiplier
		ModLoaderLog.info(
			"%s sell price x%.0f = %.0f" % [_sellable.itemID, multiplier, item.itemSellPrice],
			LOG_NAME
		)
