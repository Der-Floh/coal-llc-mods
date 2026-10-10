extends Object

# bullet_pierce: extra breakable blocks a bullet passes through before it stops.
# Vanilla turns a bullet off when it hits a breakable tile; with pierce left, it is
# switched back on and keeps flying. Each distinct tile costs one pierce (a bullet
# lingering over one tile for a few frames does not spend more), solid tiles and
# the bullet's range still stop it. The fraction of bullet_pierce accumulates
# across shots.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-extra_passives_mod/mod_main.gd"
const TILE_SIZE := 16.0
const META_LEFT := "ingenitus_pierce_left"
const META_CELL := "ingenitus_pierce_cell"

static var _pierce_pity: float = 0.0


func fired(chain: ModLoaderHookChain, p_global_position, p_direction, p_speed, p_damage, p_distance) -> void:
	chain.execute_next([p_global_position, p_direction, p_speed, p_damage, p_distance])
	var bullet := chain.reference_object as Bullet
	bullet.remove_meta(META_CELL)
	var pierce: float = load(MOD_MAIN_PATH).level("bullet_pierce")
	var whole := int(pierce)
	_pierce_pity += pierce - whole
	var bonus := int(_pierce_pity)
	_pierce_pity -= bonus
	bullet.set_meta(META_LEFT, whole + bonus)


func _physics_process(chain: ModLoaderHookChain, delta: float) -> void:
	var bullet := chain.reference_object as Bullet
	var left: int = bullet.get_meta(META_LEFT, 0)
	if not bullet.is_live or (left <= 0 and not bullet.has_meta(META_CELL)):
		chain.execute_next([delta])
		return
	var tm := bullet.tilemap
	var cell := Vector2i((bullet.global_position / TILE_SIZE).floor())
	var on_breakable: bool = tm.is_tile_breakable_pos(bullet.global_position)
	# Still inside the block it just pierced: fly on without hitting it again.
	if on_breakable and bullet.get_meta(META_CELL, Vector2i(-2147483648, -2147483648)) == cell:
		bullet.position = bullet.position.move_toward(bullet.position + bullet.direction, bullet.speed * delta)
		if bullet._initial_pos.distance_squared_to(bullet.position) > bullet._distanceSquared:
			bullet.turn_off()
		return
	var hits_block: bool = on_breakable and tm.isTileAlive(bullet.position)
	chain.execute_next([delta])
	if hits_block and not bullet.is_live and left > 0 \
			and bullet._initial_pos.distance_squared_to(bullet.position) <= bullet._distanceSquared:
		bullet.is_live = true
		bullet.visible = true
		bullet.set_meta(META_LEFT, left - 1)
		bullet.set_meta(META_CELL, cell)
