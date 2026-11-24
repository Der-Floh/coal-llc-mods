extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# The ten passives behave like the game's own: read and raised by name through Passives, saved
# with the run, reset by a new one, listed in the Tab panel, and switched off by enabled=false.

const MOD_ID := "ingenitus-extra_passives_mod"
const TICK_ID := "der_floh-tick_upgrade_mod"
const SAVE_KEY := "ingenitus_extra_passives"
const PROVIDERS_META := &"coal_llc_passive_providers"
const PISTOL := "res://resources/Items/Equipment/Guns/pistols/pistol_01_shoddy.tres"
const SHOT_SOUND := "res://assets/sound/sound effects/loud-thud.wav"
const ROW_NAMES := {
	"gun_fire_rate": "Gun Fire Rate", "multi_projectile": "Extra Projectiles", "bullet_pierce": "Bullet Pierce",
	"axe_spin_speed": "Axe Spin-Up Speed", "vacuum_range": "Vacuum Range", "vacuum_power": "Vacuum Suction",
	"drill_mining_speed": "Drill Mining Speed", "earthquake_damage": "Earthquake Damage", "earthquake_radius": "Earthquake Radius",
}


func before_each() -> void:
	if await fresh_run():
		mod(MOD_ID).reset_passives()
		on_cleanup(func() -> void: mod(MOD_ID).reset_passives())


func test_passives_read_and_rise_by_name() -> void:
	expect_eq(gvars.passives.get("vacuum_range"), 0.0, "a new run starts at 0")
	gvars.passives.apply_effect("vacuum_range", 0.05)
	gvars.passives.apply_effect("bomb_radius", 0.15)
	expect_near(gvars.passives.get("vacuum_range"), 0.05, 1e-6, "vacuum_range")
	expect_near(gvars.passives.get("bomb_radius"), 0.15, 1e-6, "bomb_radius")
	expect_near(mod(MOD_ID).adjusted_bomb_radius, 0.15, 1e-6, "the bomb radius slider follows new picks at full")
	expect_eq(gvars.passives.get("no_such_passive"), null, "unknown names stay unknown")


func test_levels_survive_save_and_load() -> void:
	gvars.passives.apply_effect("bomb_radius", 0.5)
	mod(MOD_ID).adjusted_bomb_radius = 0.2
	gvars.passives.apply_effect("drill_mining_speed", 0.1)
	var saved: Dictionary = JSON.parse_string(JSON.stringify(gvars.passives.save()))
	gvars.passives.reset()
	expect_eq(gvars.passives.get("bomb_radius"), 0.0, "after reset")
	gvars.passives.load_save(saved)
	expect_eq([gvars.passives.get("bomb_radius"), gvars.passives.get("drill_mining_speed"), mod(MOD_ID).adjusted_bomb_radius], [0.5, 0.1, 0.2], "[bomb radius, drill speed, slider] after loading")


func test_old_drill_speed_saves_carry_over() -> void:
	gvars.passives.load_save({"passives": {}, SAVE_KEY: {"levels": {"drill_speed": 0.15, "bomb_radius": 0.4}}})
	expect_near(gvars.passives.get("drill_mining_speed"), 0.15, 1e-6, "drill_speed from a save before 1.0.2")
	expect_near(mod(MOD_ID).adjusted_bomb_radius, 0.4, 1e-6, "a save without a slider value keeps the full radius")
	expect_eq(gvars.passives.get("drill_speed"), null, "the old key isn't a passive any more")


func test_shares_the_passives_extension_with_tick_upgrade() -> void:
	if not require_mods([TICK_ID]):
		return
	var providers: Array = Engine.get_meta(PROVIDERS_META, []).map(func(script: Script) -> String: return script.resource_path)
	expect_eq(providers.size(), 2, "providers: %s" % [providers])
	gvars.passives.apply_effect("gun_fire_rate", 0.05)
	gvars.passives.apply_effect("poison_tick_speed", 0.1)
	expect_near(gvars.passives.get("gun_fire_rate"), 0.05, 1e-6, "Extra Passives through the shared extension")
	expect_near(gvars.passives.get("poison_tick_speed"), 0.1, 1e-6, "Tick Upgrade through the shared extension")
	on_cleanup(func() -> void: mod(TICK_ID).reset_passives())


func test_tab_panel_lists_every_earned_passive() -> void:
	if not await in_mine():
		return
	for key in mod(MOD_ID).PASSIVES:
		gvars.passives.apply_effect(key, 0.15)
	var panel = gui().find_child("PassiveBonuses", true, false)
	panel.refresh()
	var texts := []
	for row in panel.get_children():
		if row.is_queued_for_deletion():
			continue
		if row is RichTextLabel:
			texts.append(row.text)
		else:
			texts.append_array(row.find_children("*", "RichTextLabel", true, false).map(func(label) -> String: return label.text))
	for key in ROW_NAMES:
		expect(texts.has("Increase %s +15%%" % ROW_NAMES[key]), "%s row in %s" % [ROW_NAMES[key], texts])
	var slider = panel.find_child("IngenitusBombRadiusSlider", true, false)
	if expect(slider != null, "the bomb radius slider"):
		expect_eq([slider.min_value, slider.max_value, slider.value], [0.0, 0.15, 0.15], "bomb slider [min, max, value]")


func test_disabled_mod_keeps_levels_but_drops_effects() -> void:
	if not await in_mine() or not await give(PISTOL):
		return
	gvars.passives.apply_effect("gun_fire_rate", 1.0)
	use_setting(MOD_ID, "enabled", false)
	var extra_passives = mod(MOD_ID)
	player().ready_to_shoot = true
	player().on_fire_gun_attempt(0.3, load(SHOT_SOUND), 0.0, 1, 0.0, 400.0, 15.0, 200.0, 16.0)
	expect_eq(extra_passives.level("gun_fire_rate"), 0.0, "level used by the effects")
	expect_near(gvars.passives.get("gun_fire_rate"), 1.0, 1e-6, "level kept for the save")
	expect(not extra_passives.offerable("gun_fire_rate"), "not offered")
	expect_near(player().gun_cooldown.wait_time, 0.3, 1e-6, "pistol cooldown is vanilla")
