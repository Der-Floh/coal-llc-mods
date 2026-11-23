extends Object

# earthquake_damage / earthquake_radius scale the inducer's damage and radius for
# the duration of the vanilla call (the effect resource is shared, so the values
# are restored afterwards). While Earthquake Radius is in use, the radius never
# exceeds MAX_BLAST_RADIUS.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-extra_passives_mod/mod_main.gd"

# The radius is whole tiles, so the fraction a pick adds carries over to the next quake.
static var _radius_pity: float = 0.0


func physics_process(chain: ModLoaderHookChain, player, _delta: float) -> void:
	var mod_main = load(MOD_MAIN_PATH)
	var effect = chain.reference_object
	var base_radius: int = effect.radius
	var base_damage: float = effect.damage
	var radius_level: float = mod_main.level("earthquake_radius")
	# Vanilla only quakes on this frame, so the carried fraction advances once per quake.
	if radius_level > 0.0 and Input.is_action_just_released("useItem"):
		effect.radius = _bonus_radius(base_radius, radius_level, mod_main.MAX_BLAST_RADIUS)
	effect.damage = base_damage * (1.0 + mod_main.level("earthquake_damage"))
	chain.execute_next([player, _delta])
	effect.radius = base_radius
	effect.damage = base_damage


static func _bonus_radius(base: int, radius_level: float, max_radius: float) -> int:
	var exact := minf(base * (1.0 + radius_level) + _radius_pity, max_radius)
	var whole := floori(exact)
	_radius_pity = exact - whole
	return whole
