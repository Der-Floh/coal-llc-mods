# Changelog

## [1.0.1] – 2026-11-10

- Hooks are installed once the game's own scripts have loaded instead of while the mod loader starts, which in some mod combinations shrank the inventory to the pickaxe slot.

## [1.0.0] – 2026-09-25

- Initial release
- Hides the glare particles the axe and battleaxe whirl emits at full spin, which can cover the
  tiles you are mining. Runs after vanilla `_physics_process`, so spin, movement and damage are
  unchanged
- Adds an **Axe Glare** tab to the settings menu
- Config: `show_glare` (default: false), `enabled` (default: true)
