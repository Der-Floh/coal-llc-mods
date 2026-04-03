extends Object
# Fully replaces MortarManager.shoot_mortar() so the mortar pool caps at the
# user-configured value instead of the hardcoded MAX_MORTARS = 1000.

const LOG_NAME := "der_floh-game_limits_mod:MortarHook"


func shoot_mortar(chain: ModLoaderHookChain, pos: Vector2, dmg: float) -> void:
	var mm := chain.reference_object as MortarManager

	var configured_max: int = load(
		"res://mods-unpacked/der_floh-game_limits_mod/mod_main.gd"
	).get_max_mortars()

	# --- Find a free slot (same logic as vanilla) ---
	var new_required := true
	for i in range(mm.idx, mm.idx + mm.max_mortars):  # full circular scan from current position
		var j: int = i % mm.max_mortars  # wrap around the pool end
		if mm.live_mortars[j] == 0:  # 0 = in-flight/active slot is free
			mm.idx = j
			new_required = false  # reuse this slot; no pool growth needed
			break

	if new_required:
		if mm.max_mortars < configured_max:
			# Grow the pool by one slot — all parallel arrays must grow together.
			mm.max_mortars += 1
			var instance = mm.MORTAR_LITE.instantiate()
			instance.visible = false  # hidden until actually fired
			mm.mortar_collection.append(instance)
			mm.mortar_velocities.append(Vector2(0, 0))
			mm.live_mortars.append(0)
			mm.mortar_damages.append(0)
			mm.add_child(instance)
			mm.idx = mm.max_mortars - 1  # newly appended slot is always at the last index
		else:
			# Pool is at cap — buffer damage into next shot that lands
			mm.buffer_damage += dmg
			return

	# --- Launch the mortar at the chosen slot ---
	mm.mortar_collection[mm.idx].global_position = pos
	mm.mortar_velocities[mm.idx] = (
		mm.SPEED
		* Vector2(randf_range(-6.0, 6.0), -16.0).normalized()
		* Vector2(randf_range(0.9, 1.1), randf_range(0.9, 1.1))
	)
	mm.mortar_collection[mm.idx].rotation = mm.mortar_velocities[mm.idx].angle()
	mm.mortar_collection[mm.idx].visible = true
	mm.mortar_damages[mm.idx] = dmg
	if mm.buffer_damage != 0.0:
		# Flush accumulated damage from frames where the pool was full.
		mm.mortar_damages[mm.idx] = dmg + mm.buffer_damage
		mm.buffer_damage = 0.0
	mm.live_mortars[mm.idx] = 1
	mm.idx = (mm.idx + 1) % mm.max_mortars

	mm.shoot_mortar_audio(pos)
	# chain.execute_next() intentionally omitted — this fully replaces vanilla
