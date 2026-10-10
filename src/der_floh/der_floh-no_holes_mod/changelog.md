# Changelog

## [1.0.2] – 2026-06-09

### Changed

- Removed over-commented header block and `_logged_active` one-shot log from hooks file; the `Ready!` log in `mod_main._ready()` already confirms the mod is active

## [1.0.1] – 2026-06-09

### Fixed

- Hook was silently never registered: `tile_map_chunk.hooks.gd` referenced
  `DerFlohNoHolesMod` by class name, which GDScript cannot resolve for
  dynamically-loaded scripts. Replaced with `load(MOD_MAIN_PATH)` following
  the pattern used by `der_floh-effect_spread_mod`.
- Added one-time unconditional INFO log ("Active — first hole-fill pass
  complete.") so the mod confirms it is running without requiring debug mode.

## [1.0.0] – 2026-06-09

- Initial release
- Post-processes `generate_chunk` output: any underground tile that remained
  EMPTY after generation is filled with the BASIC_* background tile for its
  depth level (BASIC_CLAY 0–2, BASIC_STONE 2–5, BASIC_ICE 5–8, BASIC_FIRE
  8–11, BASIC_DARK 12, BASIC_GREEN 13, BASIC_ORANGE 14, BASIC_PURPLE 15,
  BASIC_DARKGREEN 16, BASIC_YELLOW 17, BASIC_DARKBROWN 18, BASIC_DARKBLUE 19)
- Config: `enabled` toggle (default: true), `debug_logging` (default: false)
- Compatible with der_floh-performance_mod: hooks as an outermost wrapper,
  calls chain.execute_next() first, then fills holes in the result
