extends Object

const LOG_NAME := "der_floh-effect_spread_mod:ChunkHook"


func destroy_tile(chain: ModLoaderHookChain, idx: int, tile_properties: Dictionary):
	var chunk := chain.reference_object as TileMapChunk

	var had_poison := chunk.poison_tiles.has(idx)
	var had_burn   := chunk.burn_tiles.has(idx)
	var had_wet    := chunk.wet_tiles.has(idx)

	# Snapshot effect data before vanilla destroy_tile removes the entries.
	# Use int()/float() at assignment so typed vars never receive raw Variant.
	var p_damage := 0.0
	var p_ticks  := 0
	var b_damage := 0.0
	var b_ticks  := 0

	if had_poison:
		var p_entry  := chunk.poison_tiles[idx]
		var p_slot   := int(p_entry.get("poison_idx", 0))
		p_damage = float(p_entry.get("damage", 0.0))
		p_ticks  = int(chunk.poison_tiles_set[p_slot].get(idx, 0))

	if had_burn:
		var b_entry  := chunk.burn_tiles[idx]
		var b_slot   := int(b_entry.get("burn_idx", 0))
		b_damage = float(b_entry.get("damage", 0.0))
		b_ticks  = int(chunk.burn_tiles_set[b_slot].get(idx, 0))

	chain.execute_next([idx, tile_properties])

	if not had_poison and not had_burn and not had_wet:
		return

	# TileMapChunk is a child of %Chunks (Node2D), which is a child of TileMapManager
	var tilemap := chunk.get_parent().get_parent() as TileMapManager
	if not tilemap:
		return

	var mod_main := load("res://mods-unpacked/der_floh-effect_spread_mod/mod_main.gd")
	if not mod_main.get_enabled():
		return
	var origin   := chunk.array_to_global_pos(idx)
	var radius   := int(mod_main.get_spread_radius())
	var inherit  := bool(mod_main.get_inherit_ticks())
	var fresh    := int(mod_main.get_fresh_ticks())

	if mod_main._debug:
		ModLoaderLog.info(
			"destroy_tile spread: origin=%s radius=%d poison=%s burn=%s wet=%s" % [
				str(origin), radius, str(had_poison), str(had_burn), str(had_wet)
			], LOG_NAME
		)

	# Divide out passive so it is applied exactly once inside poison/burn_tile_idx
	var p_raw := 0.0
	if had_poison:
		p_raw = p_damage / (1.0 + Gvars.passives.poison_damage)

	var b_raw := 0.0
	if had_burn:
		b_raw = b_damage / (1.0 + Gvars.passives.fire_damage)

	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			if x == 0 and y == 0:
				continue

			var nb := origin + Vector2i(x, y)
			if not tilemap.is_tile_breakable(nb):
				continue

			if had_poison:
				tilemap.poison_tile_coords(nb, p_raw, p_ticks if inherit else fresh)

			if had_burn:
				tilemap.burn_tile_coords(nb, b_raw, b_ticks if inherit else fresh)

			if had_wet:
				tilemap.wet_tile_coords(nb)
