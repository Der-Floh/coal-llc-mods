extends Object

# Vanilla's buttons look the step size up in the constant ALL_PASSIVES, which does
# not know the new passives. When one of the three offers is ours, the button text
# and the pick are handled here; anything else is passed on unchanged, so other
# mods hooking the same methods (tick_upgrade_mod, AutoPassiveChooser) still work.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-extra_passives_mod/mod_main.gd"


func set_up_buttons(chain: ModLoaderHookChain) -> void:
	var chooser := chain.reference_object as ChoosePassive
	var mod_main = load(MOD_MAIN_PATH)
	var ours := false
	for key in chooser.choose_between:
		if mod_main.PASSIVES.has(key):
			ours = true
	if not ours:
		chain.execute_next()
		return
	var buttons := [chooser.button, chooser.button_2, chooser.button_3]
	for i in 3:
		var key: String = chooser.choose_between[i]
		if mod_main.PASSIVES.has(key):
			buttons[i].text = "Increase " + mod_main.PASSIVES[key]["name"] + " +" + str(chooser.multiplier * mod_main.PASSIVES[key]["step"] * 100) + "%"
		else:
			buttons[i].text = "Increase " + key.replace("_", " ").capitalize() + " +" + str(chooser.multiplier * ChoosePassive.ALL_PASSIVES.get(key, 0.05) * 100) + "%"


func _on_button_pressed(chain: ModLoaderHookChain) -> void:
	_pick(chain, 0)


func _on_button_2_pressed(chain: ModLoaderHookChain) -> void:
	_pick(chain, 1)


func _on_button_3_pressed(chain: ModLoaderHookChain) -> void:
	_pick(chain, 2)


static func _pick(chain: ModLoaderHookChain, idx: int) -> void:
	var chooser := chain.reference_object as ChoosePassive
	var mod_main = load(MOD_MAIN_PATH)
	var key: String = chooser.choose_between[idx]
	if not chooser.live or not mod_main.PASSIVES.has(key):
		chain.execute_next()
		return
	chooser.live = false
	Gvars.passives.apply_effect(key, chooser.multiplier * mod_main.PASSIVES[key]["step"])
	chooser.get_tree().paused = false
	chooser.queue_free()
