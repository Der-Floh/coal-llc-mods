extends Object

# fix_quota_overflow: the management screen previews tomorrow's quota with
# Gvars.increaseQuota, which overflows past day 61. The line is rewritten with the
# floating-point value (see mod_main.fixed_quota).

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-bug_fixes_mod/mod_main.gd"


func _ready(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	var quota: float = load(MOD_MAIN_PATH).fixed_quota(Gvars.dayCount + 1)
	if not is_nan(quota):
		chain.reference_object.next_quota.text = "[i]Upcoming Coal Quota: " + Gconsts.add_comma_to_int(quota)
