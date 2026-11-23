# Changelog

## [1.2.3] – 2026-11-23

### Fixed

- A Max Active Mortars value below 50 or a Chunks Generated Per Frame value above 10 in the config file is corrected when you open the settings menu, like the other settings. Before, it stayed and was used.
- Max Employee Entities Drawn moves in steps of 25 like the game's own slider, so both always show the same value. Before, opening the settings menu or setting the game's slider to a value such as 1025 stored 1050.

## [1.2.2] – 2026-11-10

### Fixed

- Hooks are installed once the game's own scripts have loaded instead of while the mod loader starts, which in some mod combinations shrank the inventory to the pickaxe slot.

## [1.2.1] – 2026-10-26

### Fixed

- While the Performance Mod is active, this mod's chunk loading and electric chain code now steps aside for the Performance Mod's faster versions, which use the same settings. Depending on the load order, the slower versions here often ran instead. Update both mods together.

## [1.2.0] – 2026-06-18

### Added

- New setting: **Mod Enabled** toggle (default on). When off, all hooks (mortar cap, chunk radius, electric chain, pause-menu fix) fall through to vanilla.

## [1.1.3] – 2026-06-09

### Removed

- Debug Logging toggle from settings tab; toggle `debug_logging` via the config JSON file instead

## [1.1.2] – 2026-04-27

### Added

- Debug Logging toggle in settings tab (default: off); gates mortar-cap and electric-chain summary log messages

## [1.1.1] – 2026-04-19

### Changed

- Updated compatible game version to 1.4.1.1

## [1.1.0] – 2026-04-04

### Added

- New setting: Max Chain Reaction Tiles (range 10–5000; default 500) — configures the electric pickaxe BFS tile cap
- New setting: Max Visual Arcs (range 0–1000; default 200) — caps the number of electricity visual effect nodes spawned; higher cap has no effect on damage but increases GPU cost
- `electric_shock.gd` hook respects both new settings; works standalone without performance_mod

## [1.0.0] – 2026-04-04

- Initial release
- Settings tab "Game Limits" with: Max Active Mortars, Max Employee Entities Drawn, Chunk Load Radius, Chunks Generated Per Frame
