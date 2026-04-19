# Changelog

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
