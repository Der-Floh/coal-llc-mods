extends "res://mods-unpacked/der_floh-test_harness/integration_test.gd"

# Numbers with more than 10 digits show as 1.23e10 instead of 1.23457e+10, round-ups as 1.00e16,
# and numbers with thousands separators are unchanged.

const MOD_ID := "ingenitus-number_format_mod"
const VALUES := [1234567890.0, 12345678901.0, 9.994e15, 9.996e15, 1e10, -2.5e11]
const FORMATTED := ["1,234,567,890", "1.23e10", "9.99e15", "1.00e16", "1.00e10", "-2.50e11"]
const VANILLA := ["1,234,567,890", "1.23457e+10", "9.994e+15", "9.996e+15", "1e+10", "-2.5e+11"]


func test_large_numbers_are_short() -> void:
	var constants = tree.root.get_node("Gconsts")
	expect_eq(VALUES.map(func(value: float) -> String: return constants.add_comma_to_float_no_dp(value)), FORMATTED, "formatted values")
	expect_eq(constants.add_comma_to_int(12345678901.0), "1.23e10", "a large float through add_comma_to_int")
	expect_eq(constants.add_comma_to_int(12345678901), "12,345,678,901", "an int keeps its separators")


func test_disabled_mod_formats_like_vanilla() -> void:
	var constants = tree.root.get_node("Gconsts")
	use_setting(MOD_ID, "enabled", false)
	expect_eq(VALUES.map(func(value: float) -> String: return constants.add_comma_to_float_no_dp(value)), VANILLA, "vanilla formatting")
