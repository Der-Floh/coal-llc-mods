extends Object

const LOG_NAME := "der_floh-tick_upgrade_mod:MapManagerHook"


func apply_tile_effects(chain: ModLoaderHookChain) -> void:
	var tilemap := chain.reference_object as TileMapManager
	if DerFlohTickUpgradeMod._debug:
		ModLoaderLog.info("apply_tile_effects manager hook IS being called", LOG_NAME)
	chain.execute_next()

	# After the normal pass (live + no-collision chunks), also tick any DISABLED
	# chunk that still carries active poison or fire effects — so effects keep
	# dealing damage even when the player has moved far away.
	if not DerFlohTickUpgradeMod.get_always_tick_distant():
		return

	for chunk in tilemap.chunks_created.values():
		# Only DISABLED chunks need the extra pass; live and no-collision chunks
		# were already handled by the vanilla/perf-mod pass above.
		if chunk.state != TileMapChunk.States.DISABLED:
			continue
		if chunk.poison_tiles.is_empty() and chunk.burn_tiles.is_empty():
			continue
		# Calling apply_tile_effects routes through the TileMapChunk hook, so
		# tick-speed multipliers apply to distant tiles automatically.
		chunk.apply_tile_effects()
