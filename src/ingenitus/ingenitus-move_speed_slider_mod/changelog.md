# Changelog

## [1.0.1] – 2026-11-10

- Hooks are installed once the game's own scripts have loaded instead of while the mod loader starts, which in some mod combinations shrank the inventory to the pickaxe slot.

## [1.0.0] – 2026-09-26

- Initial release
- Walk Speed slider in the passive bonuses panel (Tab). Walking can be raised up to the current
  sprint speed (sprint passive, sprint slider and the speed quest reward all count) and never past
  it.
- The setting is stored in the mod config, not in the save, so removing the mod leaves saves
  untouched.
- Config: `enabled` (default: true), `walk_speed_bonus` (default: 0.0, set by the slider)
