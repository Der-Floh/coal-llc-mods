# Changelog

## [1.3.2] – 2026-06-09

### Fixed

- `tile_map_manager.hooks.gd` referenced `DerFlohPerfMod._debug` by class name,
  silently preventing all hooks in that file (`load_chunks`, `apply_tile_effects`)
  from registering. Replaced with `load(MOD_MAIN_PATH)._debug`.

## [1.3.1] – 2026-06-09

### Removed

- Settings tab (Debug Logging was its only control); toggle `debug_logging` via the config JSON file instead

## [1.3.0] – 2026-04-27

### Added

- Settings tab with Debug Logging toggle (default: off); gates load_chunks zone-rebuild stats in `tile_map_manager.hooks.gd`

## [1.2.0] – 2026-04-19

### Added

- Optimised `lvl_from_global_pos_TIGHTFUNNEL`: computes `abs(x - 14)` once per tile instead of up to 19 times

### Changed

- Updated compatible game version to 1.4.1.1

## [1.1.0] – 2026-04-04

### Added

- `electric_shock._physics_process` hook: replaces the O(n²) array membership scan with an O(1) Dictionary hit-set, inlines the 4-neighbour checks to eliminate per-frontier-tile array allocations, and caps visual arc nodes to `max_electric_visuals` from game_limits_mod config (fallback: 200)

## [1.0.0] – 2026-04-04

- Initial release
- Optimised `load_chunks`: skips zone rebuild when no chunkloader crosses a chunk boundary; uses O(1) shadow dict for queue deduplication
- Optimised `apply_tile_effects`: iterates `chunks_created` dict directly (no `get_children()` allocation per tick); skips idle outer-ring chunks
- Optimised `generate_chunk`: pre-filtered per-level tile bucket sorted rarest-first; inlined `set_cell()` call; falls back to vanilla for `only_coal` path
- Optimised `lvl_from_global_pos_STANDARD/FUNNEL/SKY_MINE/SHALLOW`: computes boundary jitter angle once per tile instead of once per depth threshold
- Optimised `generate_chests`: replaces blocking `load()` per chest with a module-level `preload()`
