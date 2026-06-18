## [1.3.0] – 2026-06-18

### Added

- New setting: **Mod Enabled** toggle (default on). When off, tick-speed passives are not injected into the passive chooser, no extra tick loops run, and distant-tile ticking is suspended.

## [1.2.10] – 2026-06-17

### Fixed

- Mod failed to load entirely — hooks never registered, so the tick-speed passives
  stopped appearing in NanobotZ-AutoPassiveChooser. Root cause: the tick-speed state was
  stored on a `Gvars` script extension, and reading those extension-added properties from
  other scripts kept producing compile errors (`mod_main.gd` would not compile, `new()`
  returned null, `_init()` never ran). Fixed by dropping the `Gvars` script extension
  entirely: `poison_tick_speed` / `fire_tick_speed` now live as `static var`s on
  `DerFlohTickUpgradeMod`, exposed via `get_*` / `add_*` static helpers and read by hooks
  through `load(MOD_MAIN_PATH)` — the pattern the rest of the mod suite uses. Behaviour is
  unchanged (both default to 1.0 and persist for the process).

## [1.2.4] – 2026-06-09

### Fixed

- `tile_map_chunk.hooks.gd` and `tile_map_manager.hooks.gd` referenced
  `DerFlohTickUpgradeMod` by class name (for `_debug`, `get_preserve_duration`,
  `get_always_tick_distant`), silently preventing all hooks from registering.
  Replaced all references with `load(MOD_MAIN_PATH)`.

## [1.2.3] – 2026-06-09

### Removed

- Debug Logging toggle from settings tab; toggle `debug_logging` via the config JSON file instead

## [1.2.2] – 2026-04-27

### Changed

- Replaced one-shot `[DIAG]` static-flag logging with a proper `debug_logging` config toggle (in-game settings tab, default: off)

## [1.2.1] – 2026-04-26

### Changed

- Added diagnostic logging (`[DIAG]` prefix) to `tile_map_chunk.hooks.gd`,
  `tile_map_manager.hooks.gd`, and `mod_main._ready()` to trace hook registration
  and tick-speed execution. All diagnostic logs are one-shot to avoid spam.

## [1.2.0] – 2026-04-26

### Added

- New setting: **Preserve Effect Duration** (default on). When enabled, the tick
  count stored per tile is scaled by the tick speed multiplier so total effect
  duration stays constant even as ticks fire faster. Controlled via `poison_tile_idx`
  and `burn_tile_idx` hooks on `tile_map_chunk.gd`.
- Poison/fire tick speed now shown in the Tab-menu passive bonuses panel
  (`passive_bonuses.gd` hook). Values appear as "Increase Poison Tick Speed +X%"
  entries alongside vanilla passive rows.

## [1.1.0] – 2026-04-26

### Added

- Hooks `_profession_effect` on all 22 profession scripts so that `poison_tick_speed`
  and `fire_tick_speed` appear in the NanobotZ-AutoPassiveChooser priority settings
  for every profession. Auto-selection now works as expected when those passives are
  enabled and prioritised in AutoPassiveChooser's settings.

## [1.0.0] – 2026-04-26

- Initial release.
- Passive upgrades for poison tick speed and fire tick speed, offered by the
  in-game passive chooser when the player has a poison gun, poison staff, or
  flamethrower equipped. Each upgrade adds +10 % to the respective tick rate
  (total DPS scales linearly).
- Settings tab toggle: "Always Tick Distant Tiles" — when enabled, poison and
  fire effects continue ticking even on chunks outside the player's load radius
  (default: on).
