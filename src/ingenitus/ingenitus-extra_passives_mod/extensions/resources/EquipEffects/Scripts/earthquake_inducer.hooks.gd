extends Object

# earthquake_damage / earthquake_radius scale the inducer's damage and radius for
# the duration of the vanilla call (the effect resource is shared, so the values
# are restored afterwards). The radius never exceeds MAX_BLAST_RADIUS.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-extra_passives_mod/mod_main.gd"


func physics_process(chain: ModLoaderHookChain, player, _delta: float) -> void:
	var mod_main = load(MOD_MAIN_PATH)
	var effect = chain.reference_object
	var base_radius: int = effect.radius
	var base_damage: float = effect.damage
	effect.radius = int(minf(base_radius * (1.0 + mod_main.level("earthquake_radius")), mod_main.MAX_BLAST_RADIUS))
	effect.damage = base_damage * (1.0 + mod_main.level("earthquake_damage"))
	chain.execute_next([player, _delta])
	effect.radius = base_radius
	effect.damage = base_damage
