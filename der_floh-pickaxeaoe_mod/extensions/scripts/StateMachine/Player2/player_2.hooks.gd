# Hook file for res://scripts/StateMachine/Player2/player_2.gd
# Replaces mine_action() so that both the electric pickaxe and the AOE ability
# deal full (1.0) damage to every affected tile, instead of the vanilla
# reduced values (electric: 0.8 chain multiplier, AOE: 0.3 ratio).
extends Object

const LOG_NAME := "der_floh-pickaxeaoe_mod:Hook"


# Replacement for player.apply_electric_shock() that prevents the initial tile
# from being damaged twice. Vanilla's ElectricShock never adds the initial tile
# to _tiles_hit_all, so the spreading chain re-visits it on the second frame.
# We add it after _ready() fires to block that second hit.
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
		if DerFlohPickaxeAoeMod._debug:
			ModLoaderLog.info("Blocked double-damage on initial tile %s" % str(initial_coord), LOG_NAME)


func mine_action(chain: ModLoaderHookChain) -> void:
	if DerFlohPickaxeAoeMod._debug:
		ModLoaderLog.info("mine_action hook called", LOG_NAME)

	var player := chain.reference_object as Player
	if player == null:
		ModLoaderLog.error("chain.reference_object could not be cast to Player — got: %s" % str(chain.reference_object), LOG_NAME)
		chain.execute_next()
		return

	if DerFlohPickaxeAoeMod._debug:
		ModLoaderLog.info("player cast OK | able_to_mine=%s mine_where_mouse_is=%s ReadyToMine=%s ray_cast_colliding=%s" % [
			str(player.able_to_mine), str(player.mine_where_mouse_is),
			str(player.ReadyToMine), str(player.ray_cast_tool.is_colliding())
		], LOG_NAME)

	# Convert mining speed into a damage multiplier: baseline speed 25 = 1.0×, higher speed = more damage.
	var speed_bonus_damage: float = (max(25.0, (1 + Gvars.passives.player_pickaxe_mining_speed)) / 25.0)
	var mine_damage: float = player.pickaxe_strength * player.strength_buff * (1 + Gvars.passives.player_pickaxe_mining_damage) * speed_bonus_damage

	if DerFlohPickaxeAoeMod._debug:
		ModLoaderLog.info("mine_damage=%s electric_shock_on=%s aoe_strikes=%s" % [
			str(mine_damage), str(player.electric_shock_on), str(player.aoe_strikes)
		], LOG_NAME)

	if player.able_to_mine and player.mine_where_mouse_is and player.ReadyToMine:
		if DerFlohPickaxeAoeMod._debug:
			ModLoaderLog.info("branch: mouse-aimed strike", LOG_NAME)
		player.pickaxe_strike.pitch_scale = randf_range(0.9, 1.1)
		player.pickaxe_strike.play()

		if player.electric_shock_on:
			if DerFlohPickaxeAoeMod._debug:
				ModLoaderLog.info("applying electric shock (ratio=1.0)", LOG_NAME)
			_spawn_electric_shock(player, player.pointer_global_pos, mine_damage)
		elif not player.aoe_strikes:
			# AOE skips DamageTile: BombExplode already damages the center tile
			Bus.DamageTile.emit(player.pointer_global_pos, mine_damage)

		if player.aoe_strikes:
			if DerFlohPickaxeAoeMod._debug:
				ModLoaderLog.info("applying AOE strike (ratio=1.0)", LOG_NAME)
			Bus.BombExplode.emit(player.pointer_global_pos, player.AOE_STRIKE_RADIUS, mine_damage)

		var spark_position = player.live_ray_cast.get_collision_point()
		for n in range(0, 30):
			var instance = player.SPARK.instantiate()
			instance.position = spark_position
			player.add_sibling(instance)

		player.ReadyToMine = false
		# Cooldown duration is tied to the swing animation so they finish together.
		player.pickaxe_cooldown.start(
			(player.animation_tool.current_animation_length - 0.1) / player.animation_tool.speed_scale
		)

	elif player.ray_cast_tool.is_colliding() and (player.ReadyToMine == true):
		if DerFlohPickaxeAoeMod._debug:
			ModLoaderLog.info("branch: raycast strike", LOG_NAME)
		player.pickaxe_strike.pitch_scale = randf_range(0.9, 1.1)
		player.pickaxe_strike.play()

		var ray_pos = player.ray_cast_tool.get_collision_point()
		var normal = player.ray_cast_tool.get_collision_normal()
		ray_pos = ray_pos - normal  # step one pixel inside the tile surface so the tile coord resolves correctly

		if player.electric_shock_on:
			if DerFlohPickaxeAoeMod._debug:
				ModLoaderLog.info("applying electric shock (ratio=1.0)", LOG_NAME)
			_spawn_electric_shock(player, ray_pos, mine_damage)
		elif not player.aoe_strikes:
			# AOE skips DamageTile: BombExplode already damages the center tile
			Bus.DamageTile.emit(ray_pos, mine_damage)

		if player.aoe_strikes:
			if DerFlohPickaxeAoeMod._debug:
				ModLoaderLog.info("applying AOE strike (ratio=1.0)", LOG_NAME)
			Bus.BombExplode.emit(ray_pos, player.AOE_STRIKE_RADIUS, mine_damage)

		var spark_position = ray_pos
		for n in range(0, 30):
			var instance = player.SPARK.instantiate()
			instance.position = spark_position
			player.add_sibling(instance)

		player.ReadyToMine = false
		# Same cooldown formula as the mouse-aimed branch above.
		player.pickaxe_cooldown.start(
			(player.animation_tool.current_animation_length - 0.1) / player.animation_tool.speed_scale
		)
	else:
		if DerFlohPickaxeAoeMod._debug:
			ModLoaderLog.info("branch: no conditions met — nothing fired", LOG_NAME)
	# chain.execute_next() is intentionally omitted — this fully replaces the vanilla method.
