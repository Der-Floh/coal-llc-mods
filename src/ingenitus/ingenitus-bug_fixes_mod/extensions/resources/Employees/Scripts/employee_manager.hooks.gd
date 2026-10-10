extends Object

const MOD_MAIN_PATH := "res://mods-unpacked/ingenitus-bug_fixes_mod/mod_main.gd"


# fix_negative_cash: buying the maximum affordable employees deducts
# (cash / cost) * cost, which float rounding can put a little above the cash
# held, leaving a negative balance. Vanilla's purchase (including fractional
# employees) is kept as is; only a negative result is clamped to zero.
func purchase_employee_level(chain: ModLoaderHookChain, employee_level: EmployeeLevel, count: float) -> float:
	var bought: float = chain.execute_next([employee_level, count])
	if Gvars.CashCount < 0.0 and load(MOD_MAIN_PATH).is_on("fix_negative_cash"):
		Gvars.CashCount = 0.0
	return bought
