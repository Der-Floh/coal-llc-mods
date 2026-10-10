# Changelog

## [1.0.0] – 2026-09-25

- Initial release
- Adds a **World Seed** tab to the settings menu
- With a non-zero seed, every chunk is generated from the seed, the day and the chunk's own
  position (`TileMapManager.generate_chunk` / `generate_chunk_tiles`), so terrain, ore layer
  boundaries, sprite variants and chests come out identical however the mine is explored
- The global RNG is re-randomised after each seeded chunk, so the rest of gameplay stays random
- Settings are taken when a mining day starts, so changing them mid-day never leaves a seam
- Config: `seed` (default `0` = random, vanilla), `same_every_day` (default: false — a new seeded
  mine each day), `enabled` (default: true), `debug_logging` (default: false)
