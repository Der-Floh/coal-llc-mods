# Coal LLC Mods – Combined Changelog

Suite releases group all mod updates shipped together.
Individual mod version histories live in each mod's own `changelog.md`.

---

## [1.3.0] – 2026-06-09

Two new mods, critical bug fixes for three mods that were silently inactive, and debug logging moved out of the in-game settings tab across all mods.

### der_floh-no_holes_mod (new — 1.0.2)

New mod — fills the air-pocket holes that vanilla world generation leaves in roughly 30 % of underground tiles. Post-processes `generate_chunk`: any tile that remained `EMPTY` is replaced with the `BASIC_*` background tile for its depth level.

#### Added

- Fills `EMPTY` underground tiles after each chunk generates: BASIC_CLAY 0–2 · BASIC_STONE 2–5 · BASIC_ICE 5–8 · BASIC_FIRE 8–11 · BASIC_DARK 12 · BASIC_GREEN 13 · BASIC_ORANGE 14 · BASIC_PURPLE 15 · BASIC_DARKGREEN 16 · BASIC_YELLOW 17 · BASIC_DARKBROWN 18 · BASIC_DARKBLUE 19
- Config: `enabled` (default: on), `debug_logging` (default: off)
- `optional_dependencies: ["der_floh-performance_mod"]` — hooks as outermost `generate_chunk` wrapper

---

### der_floh-tick_upgrade_mod (new — 1.2.4)

New mod — injects "Poison Tick Speed" and "Fire Tick Speed" passive upgrade options into the in-game passive chooser (shown when a poison weapon or flamethrower is equipped). Each upgrade adds +10 % to the respective tick rate. Also keeps effects ticking on out-of-range chunks.

#### Added

- Passive upgrades for Poison Tick Speed and Fire Tick Speed (+10 % per level)
- Setting: Always Tick Distant Tiles — keeps poison/fire ticking on unloaded chunks (default: on)
- Setting: Preserve Effect Duration — scales the stored tick count by the speed multiplier so duration stays constant at higher tick rates (default: on)
- Tick-speed bonuses shown in the Tab-menu passive bonuses panel
- `optional_dependencies: ["der_floh-performance_mod"]`

#### Fixed

- All hooks were silently not registering since 1.2.1: class name references in both hook files prevented GML from loading them. Tick-speed scaling, Preserve Effect Duration, and Always Tick Distant Tiles were all inactive. Fixed by replacing all bare class name references with `load(MOD_MAIN_PATH)`.

---

### der_floh-pickaxeaoe_mod (1.0.1 → 1.1.2)

#### Fixed

- `mine_action` hook was silently not registering since 1.1.0: `player_2.hooks.gd` referenced `DerFlohPickaxeAoeMod._debug` by class name. Electric pickaxe and AOE dealt reduced vanilla damage ratios instead of the intended 1.0× to all tiles. Fixed by replacing all class name references with `load(MOD_MAIN_PATH)`.
- Spark effect now uses `tilemap.sparks_manager.add_spark()` pool instead of spawning 30 individual `Spark.tscn` instances per swing

#### Removed

- Settings tab (its only control was the Debug Logging toggle); toggle `debug_logging` via the config JSON instead

---

### der_floh-performance_mod (1.2.0 → 1.3.2)

#### Fixed

- `tile_map_manager.hooks.gd` referenced `DerFlohPerfMod._debug` by class name, silently preventing both hooks in that file from registering since 1.3.0 — `load_chunks` and `apply_tile_effects` were both inactive. Fixed by replacing all class name references with `load(MOD_MAIN_PATH)`.

#### Removed

- Settings tab (its only control was the Debug Logging toggle); toggle `debug_logging` via the config JSON instead

---

### der_floh-ore_value_mod (1.0.1 → 1.0.3), der_floh-effect_spread_mod (1.0.1 → 1.0.3), der_floh-game_limits_mod (1.1.1 → 1.1.3), der_floh-passive_drop_mod (2.2.2 → 2.2.4)

#### Removed

- Debug Logging toggle from settings tab; toggle `debug_logging` via the config JSON instead

---

## [1.2.0] – 2026-04-19

Game compatibility update for Coal LLC v1.4.1.1.

### der_floh-performance_mod (1.1.0 → 1.2.0)

#### Added

- Optimised `lvl_from_global_pos_TIGHTFUNNEL` hook: computes `abs(x - 14)` once per tile instead of up to 19 times (same pattern as the existing STANDARD/FUNNEL/SKY_MINE/SHALLOW hooks)

#### Changed

- Updated compatible game version to 1.4.1.1

---

### der_floh-ore_value_mod, der_floh-effect_spread_mod, der_floh-game_limits_mod, der_floh-pickaxeaoe_mod, der_floh-passive_drop_mod

#### Changed

- Updated compatible game version to 1.4.1.1

---

## [1.1.0] – 2026-04-04

### der_floh-passive_drop_mod (1.0.0 → 2.2.1)

New mod — adds a configurable chance for ore and non-ore tiles to drop a `PassiveUpgrade` on destruction, with passive quality scaling by layer depth (mirrors the vanilla chest loot-level system).

#### Added

- Per-ore drop chance sliders (0–100 %) for all 15 ore types: Coal, Copper, Iron, Silver, Gold, Amethyst, Sapphire, Emerald, Ruby, Diamond, Pink Diamond, Spinel, Uranium, Moonstone, Onyx
- Non-Ore Blocks drop chance slider (default 0 %)
- Passive quality scales with layer depth: shallow tiles → multiplier 1×, deepest exotic-layer tiles → up to 144× (same formula as vanilla chests)
- Toggle: Weapon Drops from Chests — disable to replace weapon-scroll chest drops with a passive upgrade
- Toggle: Chest Generation — disable to suppress all chest spawning (default: off)
- Toggle: Auto-Collect Dropped Passives — triggers the passive chooser screen immediately on drop; integrates with NanobotZ-AutoPassiveChooser for fully automatic selection (default: off)
- Scrollable settings tab in the in-game settings menu
- `optional_dependencies`: `der_floh-performance_mod`, `NanobotZ-AutoPassiveChooser`

#### Default drop chances

Coal 1 % · Copper 2 % · Iron 4 % · Silver 6 % · Gold 8 % · Amethyst 10 % · Sapphire 20 % · Emerald 30 % · Ruby 40 % · Diamond 50 % · Pink Diamond 60 % · Spinel 70 % · Uranium 80 % · Moonstone 90 % · Onyx 100 %

---

### der_floh-game_limits_mod (1.0.0 → 1.1.0)

#### Added

- New setting: Max Chain Reaction Tiles (range 10–5000; default 500) — caps the electric pickaxe BFS tile count
- New setting: Max Visual Arcs (range 0–1000; default 200) — limits electricity visual-effect nodes (higher values increase GPU cost but not damage)

---

### der_floh-performance_mod (1.0.0 → 1.1.0)

#### Added

- `electric_shock._physics_process` hook: replaces O(n²) array membership scan with O(1) Dictionary hit-set, inlines 4-neighbour checks to eliminate per-frontier-tile allocations, and caps visual arc nodes via `max_electric_visuals` from game_limits_mod config (fallback: 200)

---

## [1.0.0] – 2026-04-04

- Initial release of the mod suite
- Included mods: `der_floh-ore_value_mod`, `der_floh-effect_spread_mod`, `der_floh-game_limits_mod`, `der_floh-performance_mod`, `der_floh-pickaxeaoe_mod`
