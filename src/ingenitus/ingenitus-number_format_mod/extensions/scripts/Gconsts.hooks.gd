extends Object

# Vanilla add_comma_to_float_no_dp formats values up to 10 digits with thousands
# separators and falls back to String.num_scientific above that, which prints a
# six-significant-digit mantissa and a signed exponent ("1.23457e+11"). Only that
# fallback is replaced; everything vanilla prints with separators is untouched.

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-number_format_mod/mod_main.gd"


func add_comma_to_float_no_dp(chain: ModLoaderHookChain, value: float) -> String:
	var text: String = chain.execute_next([value])
	if not "e" in text:
		return text
	var mod_main = load(MOD_MAIN_PATH)
	if not mod_main.get_enabled():
		return text
	return mod_main.short_scientific(value)
