extends Object

const LOG_NAME := "der_floh-tick_upgrade_mod:PassiveHook"

# Per-upgrade increment for each custom tick-speed passive.
# Format mirrors ChoosePassive.ALL_PASSIVES: base_amount * multiplier = % gained.
const MOD_PASSIVES: Dictionary = {
	"poison_tick_speed": 0.1,  # +10 % per upgrade level
	"fire_tick_speed":   0.1,
}

# Weapon itemTypes that unlock the corresponding tick-speed passive.
const POISON_TICK_WEAPONS: Array = ["poison_gun", "poison_staff"]
const FIRE_TICK_WEAPONS: Array   = ["flamethrower"]


func _ready(chain: ModLoaderHookChain) -> void:
	var self_obj := chain.reference_object as ChoosePassive
	# Full replacement — do NOT call chain.execute_next().
	# Replicates vanilla _ready() then injects our tick-speed passives into
	# leftover_options before the 3-slot selection algorithm runs.
	self_obj.process_mode = Node.PROCESS_MODE_ALWAYS
	self_obj.get_tree().paused = true
	self_obj.live = true
	self_obj.choose_between = []

	var data := {"unlocked_passives": []}
	data = Gvars.profession._profession_effect(data)
	self_obj.x = data["unlocked_passives"]
	var player_inventory: Inventory = load("res://resources/Inventories/PlayerInventory.tres")

	var leftover_options: Array = self_obj.x.duplicate()

	# Scan inventory once to know which weapon types the player has equipped.
	var has_poison_weapon := false
	var has_fire_weapon   := false
	for inv_item in player_inventory.items:
		var item: Item = inv_item.item
		if item == null:
			continue
		if item.itemType in POISON_TICK_WEAPONS:
			has_poison_weapon = true
		if item.itemType in FIRE_TICK_WEAPONS:
			has_fire_weapon = true

	# Add tick-speed passives to the pool so the selection algorithm can pick them.
	if has_poison_weapon and "poison_tick_speed" not in leftover_options:
		leftover_options.append("poison_tick_speed")
	if has_fire_weapon and "fire_tick_speed" not in leftover_options:
		leftover_options.append("fire_tick_speed")

	# Build the weapon-biased candidate list (mirrors vanilla PASSIVE_MAP logic).
	var choice_options: Array[String]
	for inv_item in player_inventory.items:
		var item: Item = inv_item.item
		if item == null:
			continue
		# Vanilla passives tied to this weapon
		for passive in ChoosePassive.PASSIVE_MAP.get(item.itemType, []):
			if passive in leftover_options and passive not in choice_options:
				choice_options.append(passive)
		# Our custom passives tied to this weapon
		if item.itemType in POISON_TICK_WEAPONS:
			if "poison_tick_speed" in leftover_options and "poison_tick_speed" not in choice_options:
				choice_options.append("poison_tick_speed")
		if item.itemType in FIRE_TICK_WEAPONS:
			if "fire_tick_speed" in leftover_options and "fire_tick_speed" not in choice_options:
				choice_options.append("fire_tick_speed")

	# --- Vanilla 3-slot selection algorithm (unchanged from choose_passive.gd) ---
	var first_choice: String
	if choice_options.size() == 0:
		first_choice = leftover_options.pick_random()
	elif choice_options.size() == 1:
		first_choice = [choice_options[0], leftover_options.pick_random()].pick_random()
	elif choice_options.size() == 2:
		first_choice = [choice_options.pick_random(), leftover_options.pick_random()].pick_random()
	else:
		first_choice = choice_options.pick_random()
	leftover_options.erase(first_choice)
	choice_options.erase(first_choice)

	var second_choice: String
	if choice_options.size() == 0:
		second_choice = leftover_options.pick_random()
	elif choice_options.size() == 1:
		second_choice = [choice_options[0], leftover_options.pick_random()].pick_random()
	elif choice_options.size() == 2:
		second_choice = [choice_options.pick_random(), leftover_options.pick_random()].pick_random()
	else:
		second_choice = choice_options.pick_random()
	leftover_options.erase(second_choice)
	choice_options.erase(second_choice)

	var third_choice: String
	var third_choice_options: Array[String] = ["player_sprint_speed", "player_jump_velocity"]
	for passive in third_choice_options.duplicate():
		if not leftover_options.has(passive):
			third_choice_options.erase(passive)

	if third_choice_options.size() == 0:
		third_choice = leftover_options.pick_random()
	elif third_choice_options.size() == 1:
		third_choice = [third_choice_options[0], leftover_options.pick_random()].pick_random()
	else:
		third_choice = [third_choice_options.pick_random(), leftover_options.pick_random()].pick_random()

	self_obj.choose_between = [first_choice, second_choice, third_choice]
	self_obj.choose_between.shuffle()

	self_obj.set_up_buttons()


func set_up_buttons(chain: ModLoaderHookChain) -> void:
	var self_obj := chain.reference_object as ChoosePassive

	# If none of the three current choices are our custom passives, let vanilla
	# handle the button text unchanged.
	var has_mod_passive := false
	for key in self_obj.choose_between:
		if MOD_PASSIVES.has(key):
			has_mod_passive = true
			break
	if not has_mod_passive:
		chain.execute_next()
		return

	# Full replacement: build all three button labels, substituting our base
	# amounts for slots that hold a custom passive key.
	var buttons := [self_obj.button, self_obj.button_2, self_obj.button_3]
	for i in range(3):
		var key: String = self_obj.choose_between[i]
		var base_val: float
		if MOD_PASSIVES.has(key):
			base_val = MOD_PASSIVES[key]
		else:
			# Vanilla passive — read base amount from the class constant.
			base_val = ChoosePassive.ALL_PASSIVES.get(key, 0.05)
		buttons[i].text = (
			"Increase " + key.replace("_", " ").capitalize()
			+ " +" + str(self_obj.multiplier * base_val * 100) + "%"
		)


func _on_button_pressed(chain: ModLoaderHookChain) -> void:
	_handle_button(chain, 0)


func _on_button_2_pressed(chain: ModLoaderHookChain) -> void:
	_handle_button(chain, 1)


func _on_button_3_pressed(chain: ModLoaderHookChain) -> void:
	_handle_button(chain, 2)


# Applies the passive for slot `idx`. If it's one of our custom tick-speed
# passives, updates Gvars directly (bypassing Passives.apply_effect which
# doesn't know about these properties). Otherwise falls through to vanilla.
func _handle_button(chain: ModLoaderHookChain, idx: int) -> void:
	var self_obj := chain.reference_object as ChoosePassive
	if not self_obj.live:
		return
	var key: String = self_obj.choose_between[idx]
	if not MOD_PASSIVES.has(key):
		chain.execute_next()
		return

	self_obj.live = false
	var amount: float = self_obj.multiplier * MOD_PASSIVES[key]
	match key:
		"poison_tick_speed":
			Gvars.poison_tick_speed += amount
			ModLoaderLog.info(
				"Poison tick speed upgraded to %.2f×" % Gvars.poison_tick_speed,
				LOG_NAME
			)
		"fire_tick_speed":
			Gvars.fire_tick_speed += amount
			ModLoaderLog.info(
				"Fire tick speed upgraded to %.2f×" % Gvars.fire_tick_speed,
				LOG_NAME
			)
	self_obj.get_tree().paused = false
	self_obj.queue_free()
