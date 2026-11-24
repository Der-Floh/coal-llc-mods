extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# The tick speeds are passives like the game's own: raised by apply_effect, listed in the Tab
# panel, saved with the run and reset by a new one.

const MOD_ID := "der_floh-tick_upgrade_mod"
const EXTRA_PASSIVES_ID := "ingenitus-extra_passives_mod"
const SAVE_KEY := "der_floh_tick_upgrade"
const PROVIDERS_META := &"coal_llc_passive_providers"


func before_each() -> void:
	if await fresh_run():
		mod(MOD_ID).reset_passives()


func test_apply_effect_raises_the_speeds() -> void:
	gvars.passives.apply_effect("poison_tick_speed", 0.1)
	gvars.passives.apply_effect("fire_tick_speed", 0.3)
	expect_near(gvars.passives.get("poison_tick_speed"), 0.1, 1e-6, "poison bonus")
	expect_near(gvars.passives.get("fire_tick_speed"), 0.3, 1e-6, "fire bonus")
	expect_near(mod(MOD_ID).get_poison_tick_speed(), 1.1, 1e-6, "poison multiplier")


func test_speeds_survive_save_and_load() -> void:
	gvars.passives.apply_effect("poison_tick_speed", 0.2)
	var saved: Dictionary = JSON.parse_string(JSON.stringify(gvars.passives.save()))
	expect(saved.has(SAVE_KEY), "the run save has the tick speeds")
	gvars.passives.reset()
	expect_eq(gvars.passives.get("poison_tick_speed"), 0.0, "after reset")
	gvars.passives.load_save(saved)
	expect_near(gvars.passives.get("poison_tick_speed"), 0.2, 1e-6, "after loading the save")
	gvars.passives.load_save({"passives": {}})
	expect_eq(gvars.passives.get("poison_tick_speed"), 0.0, "a save from before 1.3.3 loads at +0%")


func test_continue_restores_the_saved_day() -> void:
	if not await in_mine():
		return
	gvars.passives.apply_effect("poison_tick_speed", 0.3)
	if not _succeeded(await commands.end_day({"skip_summary": false})) or not _succeeded(await commands.finish_day({})):
		return
	gvars.passives.apply_effect("poison_tick_speed", 0.5)
	if not _succeeded(await commands.continue_run({})):
		return
	expect_near(gvars.passives.get("poison_tick_speed"), 0.3, 1e-6, "continue drops the unsaved pick")
	if await fresh_run():
		expect_eq(gvars.passives.get("poison_tick_speed"), 0.0, "a new run starts at +0%")


func test_tab_panel_lists_picked_speeds() -> void:
	if not await in_mine():
		return
	mod(MOD_ID).set_passive("poison_tick_speed", 0.3)
	expect(_tab_rows().has("Increase Poison Tick Speed +30%"), "poison row in %s" % [_tab_rows()])
	expect(not _tab_rows().any(func(row: String) -> bool: return row.contains("Fire Tick Speed")), "no fire row without a fire pick")
	use_setting(MOD_ID, "enabled", false)
	expect(not _tab_rows().any(func(row: String) -> bool: return row.contains("Tick Speed")), "no tick rows while the mod is disabled")


func test_shares_the_passives_extension_with_extra_passives() -> void:
	if not require_mods([EXTRA_PASSIVES_ID]):
		return
	var providers: Array = Engine.get_meta(PROVIDERS_META, []).map(func(script: Script) -> String: return script.resource_path)
	expect(providers.has("res://mods-unpacked/%s/mod_main.gd" % MOD_ID), "Tick Upgrade is a provider")
	expect(providers.has("res://mods-unpacked/%s/mod_main.gd" % EXTRA_PASSIVES_ID), "Extra Passives is a provider")
	gvars.passives.apply_effect("vacuum_range", 0.05)
	gvars.passives.apply_effect("poison_tick_speed", 0.1)
	var saved: Dictionary = gvars.passives.save()
	expect(saved.has(SAVE_KEY) and saved.has("ingenitus_extra_passives"), "both mods save their passives: %s" % [saved.keys()])
	mod(EXTRA_PASSIVES_ID).reset_passives()


func _tab_rows() -> Array:
	var panel = gui().find_child("PassiveBonuses", true, false)
	panel.refresh()
	return panel.get_children().filter(func(row) -> bool: return row is RichTextLabel and not row.is_queued_for_deletion()).map(func(row) -> String: return row.text)
