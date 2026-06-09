# Changelog

## [1.1.2] – 2026-06-09

### Fixed

- Hook was silently never registered since 1.1.0: `player_2.hooks.gd` referenced
  `DerFlohPickaxeAoeMod._debug` by class name, which GDScript cannot resolve for
  dynamically-loaded scripts. Replaced with `load(MOD_MAIN_PATH)._debug`.
- Spark effect after each swing now uses `tilemap.sparks_manager.add_spark()` to
  match current vanilla, instead of manually spawning 30 un-recycled `Spark.tscn`
  instances (regression from a game update that added `sparks_manager`).

## [1.1.1] – 2026-06-09

### Removed

- Settings tab (Debug Logging was its only control); toggle `debug_logging` via the config JSON file instead

## [1.1.0] – 2026-04-27

### Added

- Settings tab with Debug Logging toggle (default: off); gates all mine_action branch log messages

## [1.0.1] – 2026-04-19

### Changed

- Updated compatible game version to 1.4.1.1

## [1.0.0] – 2026-04-04

- Initial release
