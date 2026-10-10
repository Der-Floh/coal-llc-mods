extends Object

const LOG_NAME := "der_floh-pickaxeaoe_mod:Hook"
# Access mod_main via load() — dynamically-loaded class_name declarations are not
# in GDScript's global registry, so referencing DerFlohPickaxeAoeMod by name here
# silently prevents hook registration.
const MOD_MAIN_PATH := "res://mods-unpacked/der_floh-pickaxeaoe_mod/mod_main.gd"


func _spawn_electric_shock(player, pos: Vector2, damage: float) -> void:
	var instance = player.ELECTRIC_SHOCK.instantiate()
	instance.initial_global_position = pos
	instance.damage = damage
	instance.damage_ratio = 1.0
	instance.tilemap = player.tilemap
	player.add_sibling(instance)
	# _ready() has now run: initial tile was damaged but left out of _tiles_hit_all.
	# Add it so the outward chain never circles back to damage it a second time.
	var initial_coord = instance.tilemap.local_to_map(pos)
	if not instance._tiles_hit_all.has(initial_coord):
		instance._tiles_hit_all.append(initial_coord)
		if load(MOD_MAIN_PATH)._debug:
			ModLoaderLog.info("Blocked double-damage on initial tile %s" % str(initial_coord), LOG_NAME)


func mine_action(chain: ModLoaderHookChain) -> void:
	var player := chain.reference_object as Player
	if player == null:
		ModLoaderLog.error("chain.reference_object could not be cast to Player — got: %s" % str(chain.reference_object), LOG_NAME)
		chain.execute_next()
		return

	var mod_main := load(MOD_MAIN_PATH)

	# Convert mining speed into a damage multiplier: baseline speed 25 = 1.0×, higher speed = more damage.
	var speed_bonus_damage: float = (max(25.0, (1 + Gvars.passives.player_pickaxe_mining_speed)) / 25.0)
	var mine_damage: float = player.pickaxe_strength * player.strength_buff * (1 + Gvars.passives.player_pickaxe_mining_damage) * speed_bonus_damage

	if mod_main._debug:
		ModLoaderLog.info("mine_damage=%s electric_shock_on=%s aoe_strikes=%s" % [
			str(mine_damage), str(player.electric_shock_on), str(player.aoe_strikes)
		], LOG_NAME)

	if player.able_to_mine and player.mine_where_mouse_is and player.ReadyToMine:
		player.pickaxe_strike.pitch_scale = randf_range(0.9, 1.1)
		player.pickaxe_strike.play()

		if player.electric_shock_on:
			if mod_main._debug:
				ModLoaderLog.info("applying electric shock (ratio=1.0)", LOG_NAME)
			_spawn_electric_shock(player, player.pointer_global_pos, mine_damage)
		elif not player.aoe_strikes:
			# AOE skips DamageTile: BombExplode already damages the center tile
			Bus.DamageTile.emit(player.pointer_global_pos, mine_damage)

		if player.aoe_strikes:
			if mod_main._debug:
				ModLoaderLog.info("applying AOE strike (ratio=1.0)", LOG_NAME)
			Bus.BombExplode.emit(player.pointer_global_pos, player.AOE_STRIKE_RADIUS, mine_damage)

		player.tilemap.sparks_manager.add_spark(player.live_ray_cast.get_collision_point())

		player.ReadyToMine = false
		# Cooldown duration is tied to the swing animation so they finish together.
		player.pickaxe_cooldown.start(
			(player.animation_tool.current_animation_length - 0.1) / player.animation_tool.speed_scale
		)

	elif player.ray_cast_tool.is_colliding() and (player.ReadyToMine == true):
		player.pickaxe_strike.pitch_scale = randf_range(0.9, 1.1)
		player.pickaxe_strike.play()

		var ray_pos = player.ray_cast_tool.get_collision_point()
		var normal = player.ray_cast_tool.get_collision_normal()
		ray_pos = ray_pos - normal  # step one pixel inside the tile surface so the tile coord resolves correctly

		if player.electric_shock_on:
			if mod_main._debug:
				ModLoaderLog.info("applying electric shock (ratio=1.0)", LOG_NAME)
			_spawn_electric_shock(player, ray_pos, mine_damage)
		elif not player.aoe_strikes:
			# AOE skips DamageTile: BombExplode already damages the center tile
			Bus.DamageTile.emit(ray_pos, mine_damage)

		if player.aoe_strikes:
			if mod_main._debug:
				ModLoaderLog.info("applying AOE strike (ratio=1.0)", LOG_NAME)
			Bus.BombExplode.emit(ray_pos, player.AOE_STRIKE_RADIUS, mine_damage)

		player.tilemap.sparks_manager.add_spark(ray_pos)

		player.ReadyToMine = false
		# Cooldown duration is tied to the swing animation so they finish together.
		player.pickaxe_cooldown.start(
			(player.animation_tool.current_animation_length - 0.1) / player.animation_tool.speed_scale
		)
	# chain.execute_next() is intentionally omitted — this fully replaces the vanilla method.
