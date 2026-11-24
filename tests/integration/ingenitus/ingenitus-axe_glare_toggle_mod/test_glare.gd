extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# The spin glare of axes and battleaxes is hidden by default and comes back with Show glare on
# or the mod disabled; spin and damage never change.

const MOD_ID := "ingenitus-axe_glare_toggle_mod"
const DAMAGE := 30.0
const AXE_TOP_SPEED := 13.0
const BATTLEAXE_TOP_SPEED := 7.0


func before_each() -> void:
	if await in_mine():
		player().equip_axe(DAMAGE, null)
		player().equip_battleaxe(DAMAGE, null)
		on_cleanup(func() -> void:
			player().unequip_axe()
			player().unequip_battleaxe())


func test_glare_is_hidden_by_default() -> void:
	expect_eq(_glare_at_full_spin(), [false, false], "[axe, battleaxe] glare")


func test_show_glare_brings_it_back() -> void:
	use_setting(MOD_ID, "show_glare", true)
	expect_eq(_glare_at_full_spin(), [true, true], "[axe, battleaxe] glare with Show glare on")


func test_disabled_mod_shows_vanilla_glare() -> void:
	use_setting(MOD_ID, "enabled", false)
	expect_eq(_glare_at_full_spin(), [true, true], "[axe, battleaxe] glare with the mod disabled")


func test_spin_and_damage_are_unchanged() -> void:
	_glare_at_full_spin()
	var axes := [player().axe_instance, player().battleaxe_instance]
	expect_eq(axes.map(func(axe) -> float: return axe.rotation_speed), [AXE_TOP_SPEED, BATTLEAXE_TOP_SPEED], "top spin speeds")
	expect_eq(axes.map(func(axe) -> float: return axe.damage), [DAMAGE, DAMAGE], "damage")


func test_settings_tab() -> void:
	var rows := settings_rows(await open_settings(), "Axe Glare")
	expect_eq(rows, {"Mod Enabled": true, "Show axe / battleaxe spin glare": false}, "Axe Glare tab")


func _glare_at_full_spin() -> Array:
	var glare := []
	for axe in [player().axe_instance, player().battleaxe_instance]:
		axe.on = true
		axe.rotation_speed = axe.MAX_ROTATION_SPEED
		axe._physics_process(1.0 / 60.0)
		glare.append(axe.gpu_particles.emitting)
	return glare
