extends Object

const LOG_NAME := "der_floh-tick_upgrade_mod:ChunkHook"


func poison_tile_idx(chain: ModLoaderHookChain, idx: int, damage: float, ticks: int) -> void:
	var speed: float = Gvars.poison_tick_speed
	if DerFlohTickUpgradeMod._debug:
		var new_ticks := int(ticks * speed) if (speed > 1.0 and DerFlohTickUpgradeMod.get_preserve_duration()) else ticks
		ModLoaderLog.info(
			"poison_tile_idx hook called — speed=%.2f preserve=%s ticks=%d → %d" % [
				speed, str(DerFlohTickUpgradeMod.get_preserve_duration()), ticks, new_ticks
			], LOG_NAME)
	if speed > 1.0 and DerFlohTickUpgradeMod.get_preserve_duration():
		chain.execute_next([idx, damage, int(ticks * speed)])
	else:
		chain.execute_next([idx, damage, ticks])


func burn_tile_idx(chain: ModLoaderHookChain, idx: int, damage: float, ticks: int) -> void:
	var speed: float = Gvars.fire_tick_speed
	if speed > 1.0 and DerFlohTickUpgradeMod.get_preserve_duration():
		chain.execute_next([idx, damage, int(ticks * speed)])
	else:
		chain.execute_next([idx, damage, ticks])


func apply_tile_effects(chain: ModLoaderHookChain) -> void:
	var chunk := chain.reference_object as TileMapChunk
	if DerFlohTickUpgradeMod._debug:
		ModLoaderLog.info("apply_tile_effects chunk hook IS being called", LOG_NAME)
	chain.execute_next()

	var poison_speed: float = Gvars.poison_tick_speed
	if poison_speed > 1.0 and chunk.t % TileMapChunk.POISON_TICK_LENGTH == 0:
		if DerFlohTickUpgradeMod._debug:
			ModLoaderLog.info(
				"firing extra poison loops — speed=%.2f extra=%d chunk.t=%d" % [
					poison_speed, int(poison_speed) - 1, chunk.t
				], LOG_NAME)
		var extra := int(poison_speed) - 1
		for _i in range(extra):
			chunk.poisons_loop()
		if randf() < fmod(poison_speed, 1.0):
			chunk.poisons_loop()

	var fire_speed: float = Gvars.fire_tick_speed
	if fire_speed > 1.0 and chunk.t % TileMapChunk.BURN_TICK_LENGTH == 0:
		var extra := int(fire_speed) - 1
		for _i in range(extra):
			chunk.burns_loop()
		if randf() < fmod(fire_speed, 1.0):
			chunk.burns_loop()
