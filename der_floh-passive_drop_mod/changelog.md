# Changelog

## [2.2.2] – 2026-04-19

### Changed

- Updated compatible game version to 1.4.1.1

## [2.2.1] – 2026-04-04

### Changed

- Chest generation is now disabled by default

## [2.2.0] – 2026-04-04

### Changed

- Set per-ore default drop chances to reflect ore rarity: Coal 1%, Copper 2%, Iron 4%, Silver 6%, Gold 8%, Amethyst 10%, Sapphire 20%, Emerald 30%, Ruby 40%, Diamond 50%, Pink Diamond 60%, Spinel 70%, Uranium 80%, Moonstone 90%, Onyx 100%
- Slider reset button (↩) now resets each ore to its individual default instead of the old shared 5% default

## [2.1.1] – 2026-04-04

### Fixed

- Ore sliders all showed "Brightness" / 50 because properties were set before `add_child`; `@onready` vars are only valid after the node enters the scene tree

## [2.1.0] – 2026-04-04

### Changed

- Replaced per-ore SpinBox number inputs with HSlider controls (0–100 %) — value label shows integer percentage

## [2.0.0] – 2026-04-04

### Breaking

- Replaced single global "Passive Drop Chance" slider with individual per-ore SpinBox controls (0–100 %) for all 15 ore types — existing config values are reset to defaults
- Removed "Ore Rarity Scales Drop Chance" toggle (replaced by simply setting different per-ore values)
- Removed "Non-Ore Blocks Also Drop Passives" toggle (replaced by setting the "Non-Ore Blocks" chance > 0)

### Added

- Per-ore drop chance: Coal, Copper, Iron, Silver, Gold, Amethyst, Sapphire, Emerald, Ruby, Diamond, Pink Diamond, Spinel, Uranium, Moonstone, Onyx (each default 5 %)
- Non-Ore Blocks drop chance (default 0 %)
- Passive quality now scales with layer depth, mirroring the chest loot_level system: shallow tiles yield multiplier 1×, deepest exotic-layer tiles yield up to 144× (same formula as vanilla chests)

## [1.2.0] – 2026-04-04

### Added

- New setting: Auto-Collect Dropped Passives — when enabled, ore drops trigger the passive chooser screen immediately instead of spawning a world item; integrates with NanobotZ-AutoPassiveChooser so it auto-selects the best passive without any player interaction (default: off)
- `NanobotZ-AutoPassiveChooser` added to `optional_dependencies` to ensure correct load order

### Fixed

- Vertical spacing on settings tab: VBox now shrinks to content height instead of distributing blank space between controls

## [1.1.0] – 2026-04-04

### Fixed

- Chest generation toggle now works correctly when `der_floh-performance_mod` is also active (fixed hook execution order via `optional_dependencies`)

### Added

- New setting: Non-Ore Blocks Also Drop Passives — when enabled, all destroyed blocks (not just ore tiles) can drop a passive (default: off)
- New setting: Ore Rarity Scales Drop Chance — when enabled, rarer ores have a proportionally higher drop chance (coal: 0.5×, pink diamond: 10×) (default: off)

## [1.0.0] – 2026-04-04

- Initial release
- Configurable chance (0–100 %) for ore tiles to drop a PassiveUpgrade on destruction
- Toggle to enable/disable weapon-scroll drops from chests (replaces them with a passive upgrade)
- Toggle to enable/disable chest generation entirely
- Settings tab in the in-game settings menu
