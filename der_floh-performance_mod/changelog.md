# Changelog

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
