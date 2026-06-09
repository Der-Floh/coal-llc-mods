extends Object

const LOG_NAME := "der_floh-tick_upgrade_mod:ChunkHook"
# Access mod_main via load() — dynamically-loaded class_name declarations are not
# in GDScript's global registry, so referencing DerFlohTickUpgradeMod by name here
# silently prevents hook registration.
const MOD_MAIN_PATH := "res://mods-unpacked/der_floh-tick_upgrade_mod/mod_main.gd"


func poison_tile_idx(chain: ModLoaderHookChain, idx: int, damage: float, ticks: int) -> void:
	var speed: float = Gvars.poison_tick_speed
	var mod_main := load(MOD_MAIN_PATH)
	if mod_main._debug:
		var new_ticks := int(ticks * speed) if (speed > 1.0 and mod_main.get_preserve_duration()) else ticks
		ModLoaderLog.info(
			"poison_tile_idx hook called — speed=%.2f preserve=%s ticks=%d → %d" % [
				speed, str(mod_main.get_preserve_duration()), ticks, new_ticks
			], LOG_NAME)
	if speed > 1.0 and mod_main.get_preserve_duration():
		chain.execute_next([idx, damage, int(ticks * speed)])
	else:
		chain.execute_next([idx, damage, ticks])


func burn_tile_idx(chain: ModLoaderHookChain, idx: int, damage: float, ticks: int) -> void:
	var speed: float = Gvars.fire_tick_speed
	if speed > 1.0 and load(MOD_MAIN_PATH).get_preserve_duration():
		chain.execute_next([idx, damage, int(ticks * speed)])
	else:
		chain.execute_next([idx, damage, ticks])


func apply_tile_effects(chain: ModLoaderHookChain) -> void:
	var chunk := chain.reference_object as TileMapChunk
	var mod_main := load(MOD_MAIN_PATH)
	if mod_main._debug:
		ModLoaderLog.info("apply_tile_effects chunk hook IS being called", LOG_NAME)
	chain.execute_next()

	var poison_speed: float = Gvars.poison_tick_speed
	if poison_speed > 1.0 and chunk.t % TileMapChunk.POISON_TICK_LENGTH == 0:
		if mod_main._debug:
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
