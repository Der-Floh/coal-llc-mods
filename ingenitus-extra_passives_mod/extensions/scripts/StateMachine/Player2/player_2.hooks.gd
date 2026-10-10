extends Object

# gun_fire_rate divides the gun cooldown (never below GUN_COOLDOWN_FLOOR);
# multi_projectile adds bullets per shot. The whole part is guaranteed and the
# fraction accumulates across shots (0.5 = one extra bullet every other shot).
# Both only change the arguments vanilla fires with.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-extra_passives_mod/mod_main.gd"

static var _projectile_pity: float = 0.0


func on_fire_gun_attempt(chain: ModLoaderHookChain, cooldown_time: float, gun_shot_audio_stream: AudioStream, gun_recoil: float,
		bullet_count: int, bullet_spread: float, bullet_speed: float, bullet_damage: float, bullet_max_distance: float,
		weapon_length: float, is_reloaded: bool = false, gun_reload_audio_stream: AudioStream = AudioStream.new(),
		gun_reload_delay_time: float = 0) -> void:
	var mod_main = load(MOD_MAIN_PATH)
	var player := chain.reference_object as Player
	if player.ready_to_shoot:
		var rate: float = mod_main.level("gun_fire_rate")
		if rate > 0.0:
			cooldown_time = maxf(cooldown_time / (1.0 + rate), minf(cooldown_time, mod_main.GUN_COOLDOWN_FLOOR))
		var extra_level: float = mod_main.level("multi_projectile")
		if extra_level > 0.0:
			var whole := int(extra_level)
			_projectile_pity += extra_level - whole
			var bonus := int(_projectile_pity)
			_projectile_pity -= bonus
			var extra := whole + bonus
			if extra > 0:
				bullet_count += extra
				bullet_spread = maxf(bullet_spread, mod_main.MULTI_MIN_SPREAD)
	chain.execute_next([cooldown_time, gun_shot_audio_stream, gun_recoil, bullet_count, bullet_spread,
		bullet_speed, bullet_damage, bullet_max_distance, weapon_length, is_reloaded,
		gun_reload_audio_stream, gun_reload_delay_time])
