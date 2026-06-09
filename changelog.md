# Coal LLC Mods – Combined Changelog

Suite releases group all mod updates shipped together.
Individual mod version histories live in each mod's own `changelog.md`.

---

## [1.3.0] – 2026-06-09

### der_floh-no_holes_mod (new — 1.0.2)

New mod — post-processes `generate_chunk` output and fills any underground tile that
remained `EMPTY` after generation with the correct `BASIC_*` background tile for its
depth level. Eliminates the air-pocket holes that vanilla world generation leaves in
roughly 30 % of underground tiles.

- Depth → fill tile mapping: BASIC_CLAY 0–2 · BASIC_STONE 2–5 · BASIC_ICE 5–8 ·
  BASIC_FIRE 8–11 · BASIC_DARK 12 · BASIC_GREEN 13 · BASIC_ORANGE 14 · BASIC_PURPLE 15 ·
  BASIC_DARKGREEN 16 · BASIC_YELLOW 17 · BASIC_DARKBROWN 18 · BASIC_DARKBLUE 19
- Config: `enabled` toggle (default: on), `debug_logging` (default: off)
- `optional_dependencies: ["der_floh-performance_mod"]` — wraps as outermost hook so it
  fills holes in whatever generate_chunk produces, regardless of whether performance_mod
  is installed

---

### Critical bug fix: hook registration failure (class_name references)

Three mods were silently failing to register their hooks since their last respective
updates, meaning the features listed below were doing nothing at runtime.

Root cause: referencing a mod's own `class_name` (e.g. `DerFlohPickaxeAoeMod._debug`)
from a hooks file prevents GML from loading the file — GDScript cannot resolve
`class_name` declarations of scripts that are loaded dynamically at runtime. The fix
in all cases is `load(MOD_MAIN_PATH)` instead.

#### der_floh-pickaxeaoe_mod (1.1.1 → 1.1.2)

Broken since 1.1.0 (when debug logging was added). The `player_2.hooks.gd`
class_name reference caused the entire hook to not register, so vanilla
`mine_action` ran instead — electric pickaxe and AOE dealt reduced vanilla damage
ratios instead of the intended 1.0× to all tiles.

Also fixed in the same release: spark effect now uses
`tilemap.sparks_manager.add_spark()` to match current vanilla (the old manual
`Spark.tscn` × 30 pattern was from an earlier game version).

#### der_floh-performance_mod (1.3.1 → 1.3.2)

The `DerFlohPerfMod._debug` reference in `tile_map_manager.hooks.gd` prevented
**both** hooks in that file from registering — `load_chunks` (skip-rebuild
optimisation) and `apply_tile_effects` (direct dict iteration) were both inactive.

#### der_floh-tick_upgrade_mod (1.2.3 → 1.2.4)

The most severe case: class_name references for `_debug`, `get_preserve_duration`,
and `get_always_tick_distant` in both `tile_map_chunk.hooks.gd` and
`tile_map_manager.hooks.gd` prevented all four hooks from registering. Tick-speed
scaling, Preserve Effect Duration, and Always Tick Distant Tiles were all silently
inactive.

---

### Settings cleanup: debug logging moved to config file (all mods)

The Debug Logging toggle has been removed from the in-game settings tab in all mods.
Toggle it by editing the config JSON directly:

`%AppData%\Godot\app_userdata\Coal LLC\mods-storage\<mod_id>\configs\user.json`

Set `"debug_logging": true` to enable. Affected mods and their new versions:

| Mod                        | Version       |
| -------------------------- | ------------- |
| der_floh-ore_value_mod     | 1.0.2 → 1.0.3 |
| der_floh-effect_spread_mod | 1.0.2 → 1.0.3 |
| der_floh-game_limits_mod   | 1.1.2 → 1.1.3 |
| der_floh-pickaxeaoe_mod    | 1.1.0 → 1.1.1 |
| der_floh-performance_mod   | 1.3.0 → 1.3.1 |
| der_floh-passive_drop_mod  | 2.2.3 → 2.2.4 |
| der_floh-tick_upgrade_mod  | 1.2.2 → 1.2.3 |

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
