extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Each passive changes what its README row says: gun cooldowns, extra bullets and pierce, axe
# spin-up, vacuum hose and nozzle, drill speed, earthquake damage and radius, bomb radius.

const MOD_ID := "ingenitus-extra_passives_mod"
const SHOT_SOUND := "res://assets/sound/sound effects/loud-thud.wav"
const BULLET_SCENE := "res://scenes/Bullet.tscn"
const DRILL_SCENE := "res://scenes/Machinery/drill_bit_2.tscn"
const BOMB_SCENE := "res://scenes/Bomb.tscn"
const INDUCER := "res://resources/Items/Equipment/earthquake_inducers/earthquake_inducer_01.tres"
# Pistol, shotgun, rifle (and minigun) cooldowns in seconds; rifles are already below the 0.05 s floor.
const COOLDOWNS := [0.3, 0.7, 0.033, 0.3]
const SPARE_BULLETS := 20
const AXE_DAMAGE := 30.0
const VACUUM_BASE_LENGTH := 480
const FAKE_PLAYER_SOURCE := "extends RefCounted\nvar calls = []\nvar tilemap\nvar global_position = Vector2.ZERO\nvar item_equipped\nfunc earthquake_pos(_position, damage, radius):\n\tcalls.append([damage, radius])\n"


func before_each() -> void:
	if await in_mine():
		mod(MOD_ID).reset_passives()
		on_cleanup(func() -> void: mod(MOD_ID).reset_passives())


func test_gun_fire_rate_divides_slow_gun_cooldowns() -> void:
	expect_eq(await _shoot_once_each("gun_fire_rate", 1.0), [0.15, 0.35, 0.033, 0.15], "cooldowns at +100%")
	expect_eq(await _shoot_once_each("gun_fire_rate", 13.0), [0.05, 0.05, 0.033, 0.05], "cooldowns at the +1300% cap")


func test_extra_projectiles_add_bullets() -> void:
	expect_eq(await _bullets_for_four_shots("multi_projectile", 2.0), 12, "bullets for 4 shots at +200%")
	expect_eq(await _bullets_for_four_shots("multi_projectile", 0.5), 6, "bullets for 4 shots at +50%")


func test_bullet_pierce_adds_up_across_shots() -> void:
	await _shoot_once_each("bullet_pierce", 2.0)
	expect_eq(_pierce_total(), 8, "pierce over 4 bullets at +200%")
	await _shoot_once_each("bullet_pierce", 0.5)
	expect_eq(_pierce_total(), 2, "pierce over 4 bullets at +50%")


func test_axe_spin_up_speed() -> void:
	var p = player()
	p.equip_axe(AXE_DAMAGE, null)
	p.equip_battleaxe(AXE_DAMAGE, null)
	on_cleanup(func() -> void:
		player().unequip_axe()
		player().unequip_battleaxe())
	var vanilla := _spin(p)
	mod(MOD_ID).set_passive("axe_spin_speed", 1.0)
	var doubled := _spin(p)
	for i in 2:
		expect_near(doubled[i].up, vanilla[i].up * 2.0, 1e-4, "spin-up per step doubles at +100%")
		expect(doubled[i].down < vanilla[i].down, "spin-down is faster: %s vs %s" % [doubled[i].down, vanilla[i].down])
		expect_eq([doubled[i].top, doubled[i].damage], [vanilla[i].top, AXE_DAMAGE], "top speed and damage are unchanged")


func test_vacuum_passives_apply_at_once_without_compounding() -> void:
	if not await set_vacuum(1):
		return
	var vacuums: Array = tree.get_nodes_in_group(mod(MOD_ID).VACUUM_GROUP)
	if not expect(not vacuums.is_empty(), "a vacuum was built"):
		return
	var vacuum = vacuums[0]
	expect_eq(vacuum.vacuum_length, VACUUM_BASE_LENGTH, "hose length at level 1")
	gvars.passives.apply_effect("vacuum_range", 0.05)
	gvars.passives.apply_effect("vacuum_power", 0.1)
	expect_eq([vacuum.vacuum_length, snappedf(vacuum.suck_end.scale.x, 0.001)], [504, 1.1], "[hose, nozzle scale] right after the picks")
	gvars.passives.apply_effect("vacuum_range", 0.05)
	expect_eq(vacuum.vacuum_length, 528, "a second Vacuum Range pick adds to the base, not the boosted length")


func test_drill_speed_also_applies_to_placed_drills() -> void:
	gvars.passives.apply_effect("drill_mining_speed", 0.25)
	var drill = load(DRILL_SCENE).instantiate()
	drill.tilemap = tilemap()
	game.current_node.add_child(drill)
	drill.global_position = player().global_position + Vector2(48, 0)
	on_cleanup(func() -> void: drill.queue_free())
	expect_near(drill.animation_player.speed_scale, 1.25, 1e-6, "a new drill at +25%")
	gvars.passives.apply_effect("drill_mining_speed", 0.25)
	expect_near(drill.animation_player.speed_scale, 1.5, 1e-6, "the placed drill after another pick")


func test_earthquake_damage_and_radius() -> void:
	var extra_passives = mod(MOD_ID)
	extra_passives.set_passive("earthquake_damage", 0.5)
	extra_passives.set_passive("earthquake_radius", 1.0)
	expect_eq(_quake(10), [450.0, 20], "[damage, radius] at +50% damage, +100% radius")
	extra_passives.set_passive("earthquake_damage", 0.0)
	extra_passives.set_passive("earthquake_radius", 3.8)
	expect_eq(_quake(10), [300.0, 48], "the radius stops at 48 tiles")
	# Reset so the level is exactly 0.05; the fraction carried from earlier quakes only decides which ones round up.
	extra_passives.reset_passives()
	extra_passives.set_passive("earthquake_radius", 0.05)
	var radii := [_quake(10)[1], _quake(10)[1], _quake(10)[1], _quake(10)[1]]
	radii.sort()
	expect_eq(radii, [10, 10, 11, 11], "+5% on 10 tiles over four quakes: fractions add up")
	extra_passives.set_passive("earthquake_radius", 0.0)
	expect_eq(_quake(60)[1], 60, "another mod's 60-tile inducer is untouched without the passive")


func test_bomb_radius_and_its_limit() -> void:
	var extra_passives = mod(MOD_ID)
	gvars.passives.apply_effect("bomb_radius", 10.0)
	var cases := [[10.0, 4.0, 44.0], [0.5, 4.0, 6.0], [0.5, 40.0, 48.0], [0.5, 60.0, 48.0], [0.0, 4.0, 4.0], [0.0, 60.0, 60.0]]
	for case in cases:
		extra_passives.adjusted_bomb_radius = case[0]
		expect_eq(_explosion_radius(case[1]), case[2], "slider %s, bomb radius %s" % [case[0], case[1]])


func _shoot_once_each(key: String, level: float) -> Array:
	mod(MOD_ID).reset_passives()
	mod(MOD_ID).set_passive(key, level)
	_add_spare_bullets()
	for bullet in tree.get_nodes_in_group("bullets"):
		bullet.turn_off()
	var p = player()
	var waits := []
	for cooldown in COOLDOWNS:
		p.ready_to_shoot = true
		p.ray_cast_tool.target_position = Vector2(0, -100)
		p.on_fire_gun_attempt(cooldown, load(SHOT_SOUND), 0.0, 1, 0.0, 400.0, 15.0, 200.0, 16.0)
		waits.append(snappedf(p.gun_cooldown.wait_time, 0.001))
	return waits


func _bullets_for_four_shots(key: String, level: float) -> int:
	await _shoot_once_each(key, level)
	return tree.get_nodes_in_group("bullets").filter(func(bullet) -> bool: return bullet.is_live).size()


func _pierce_total() -> int:
	var live: Array = tree.get_nodes_in_group("bullets").filter(func(bullet) -> bool: return bullet.is_live)
	return live.reduce(func(total: int, bullet) -> int: return total + int(bullet.get_meta("ingenitus_pierce_left", 0)), 0)


func _add_spare_bullets() -> void:
	if tree.get_nodes_in_group("bullets").size() >= SPARE_BULLETS:
		return
	for i in SPARE_BULLETS:
		var bullet = load(BULLET_SCENE).instantiate()
		bullet.tilemap = tilemap()
		player().add_sibling(bullet)


static func _spin(p) -> Array:
	var results := []
	for weapon in [p.axe_instance, p.battleaxe_instance]:
		weapon.on = true
		weapon.rotation_speed = 0.0
		weapon._physics_process(0.1)
		var up: float = weapon.rotation_speed
		weapon.on = false
		weapon.rotation_speed = weapon.MAX_ROTATION_SPEED
		weapon._physics_process(0.1)
		var down: float = weapon.rotation_speed
		weapon.on = true
		weapon.rotation_speed = weapon.MAX_ROTATION_SPEED
		weapon._physics_process(0.1)
		results.append({"up": up, "down": down, "top": weapon.rotation_speed, "damage": weapon.damage})
	return results


# A stand-in player records what the inducer passes to earthquake_pos on a released useItem.
func _quake(base_radius: int) -> Array:
	var item = load(INDUCER)
	var effect = item.itemEquipEffect
	var base_damage: float = effect.damage
	effect.radius = base_radius
	var script := GDScript.new()
	script.source_code = FAKE_PLAYER_SOURCE
	script.reload()
	var stand_in = script.new()
	stand_in.tilemap = stand_in
	stand_in.item_equipped = item
	Input.action_press("useItem")
	Input.action_release("useItem")
	effect.physics_process(stand_in, 0.016)
	effect.radius = 10
	expect_eq(effect.damage, base_damage, "the inducer's own damage is restored after the quake")
	return stand_in.calls.back() if not stand_in.calls.is_empty() else [0.0, 0]


func _explosion_radius(radius: float) -> float:
	var radii := []
	var record := func(_position, blast_radius, _damage) -> void: radii.append(blast_radius)
	bus.BombExplode.connect(record)
	var bomb = load(BOMB_SCENE).instantiate()
	bomb.radius = radius
	bomb.damage = 0.0
	game.current_node.add_child(bomb)
	bomb.global_position = player().global_position + Vector2(0, -400)
	bomb._on_bomb_explode()
	bus.BombExplode.disconnect(record)
	bomb.queue_free()
	return radii.back() if not radii.is_empty() else -1.0
