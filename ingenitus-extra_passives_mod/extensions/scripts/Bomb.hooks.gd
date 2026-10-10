extends Object

# bomb_radius: the blast radius grows by the passive (as dialled back by the player)
# and is clamped at MAX_BLAST_RADIUS, so small bombs get the full benefit while the
# nuke (40) grows at most to 48. The radius is scaled only for the vanilla call.
# Vanilla plays a one-off narrator line for bombs with radius > 30 (the nuke); that
# stays tied to the bomb's own radius, not the boosted one.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-extra_passives_mod/mod_main.gd"


func _on_bomb_explode(chain: ModLoaderHookChain) -> void:
	var mod_main = load(MOD_MAIN_PATH)
	var bomb := chain.reference_object as BombScene
	var boost: float = mod_main.bomb_radius_in_use()
	if boost <= 0.0:
		chain.execute_next()
		return
	var base_radius: float = bomb.radius
	var had_dialogue: bool = BombScene.nuke_dialogue
	if base_radius <= 30:
		BombScene.nuke_dialogue = true  # not a nuke: keep the narrator quiet
	bomb.radius = minf(base_radius * (1.0 + boost), mod_main.MAX_BLAST_RADIUS)
	chain.execute_next()
	bomb.radius = base_radius
	if base_radius <= 30:
		BombScene.nuke_dialogue = had_dialogue
