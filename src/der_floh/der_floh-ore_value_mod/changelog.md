# Changelog

## [1.1.2] – 2026-10-26

### Fixed

- The mod no longer reloads the game's items at the start of every day. That brought bought one-time upgrades back into the shop and locked items unlocked during the run again, and the next save kept that state. Saves that were already affected keep it.
- The Spinel, Uranium, Moonstone and Onyx multipliers now change their sell prices.
- Coal stays worthless under the "Coal is worthless" hard modifier, whatever its multiplier.
- Changing a setting at the main menu no longer causes a script error.

## [1.1.1] – 2026-06-18

### Fixed

- Changing a sell-price multiplier or toggling Mod Enabled in the settings tab now takes effect immediately via `Gvars.reset_resources()`, instead of waiting for the next day start.

## [1.1.0] – 2026-06-18

### Added

- New setting: **Mod Enabled** toggle (default on). When off, `reset_resources` skips all multiplier application and vanilla prices are used.

## [1.0.4] – 2026-06-17

### Fixed

- The `Gvars` script extension referenced the mod's own `class_name`
  (`DerFlohOreValueMod._debug`) from a separate script. A mod's `class_name` is not in
  GDScript's global registry, so this could fail to compile and silently prevent the
  `reset_resources` override from applying — meaning sell-price multipliers may not have
  taken effect. Now reads `_debug` via the already-loaded `mod_main` reference, matching
  the pattern used elsewhere in the file.

## [1.0.3] – 2026-06-09

### Removed

- Debug Logging toggle from settings tab; toggle `debug_logging` via the config JSON file instead

## [1.0.2] – 2026-04-27

### Added

- Debug Logging toggle in settings tab (default: off); gates sell-price log messages in `Gvars.gd` extension

## [1.0.1] – 2026-04-19

### Changed

- Updated compatible game version to 1.4.1.1

## [1.0.0] – 2026-04-04

- Initial release
