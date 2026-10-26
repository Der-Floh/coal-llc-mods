# Effect Spread Mod

When a tile that still has **poison** or **fire** ticks left, or is **wet**, is destroyed, those effects spread to the breakable tiles around it, so effects you applied aren't wasted. Any destruction counts: your pickaxe, employees, bombs, and poison or fire breaking the tile itself.

## Settings

Adds an **Effect Spread** tab to the in-game settings menu. Changes apply immediately.

| Setting                                    | Default | Range   | Description                                                                                                   |
| ------------------------------------------ | ------- | ------- | ------------------------------------------------------------------------------------------------------------- |
| Mod Enabled                                | On      | -       | Off stops the spreading                                                                                       |
| Spread Radius (tiles around destroyed ore) | `3`     | 1 to 20 | How far effects spread: every breakable tile in the square around the destroyed tile, so 48 tiles at radius 3 |
| Inherit remaining ticks from destroyed ore | On      | -       | Tiles that get poison or fire take over the ticks the destroyed tile had left                                 |
| Fresh tick count (when not inheriting)     | `10`    | 1 to 50 | The ticks poison or fire gets while Inherit is off. 10 ticks last about 30 s of poison or 12 s of fire        |

- Every breakable tile spreads effects and receives them, not only ores.
- Poison and fire keep the destroyed tile's damage per tick. Wetness has no ticks, so the tick settings only apply to poison and fire.
- A tile that already burns or is poisoned takes over the spread ticks when the spread damage is at least as high as its own, which can also shorten its effect.
- Spreading chains: a tile that got an effect spreads it again when it is destroyed. With Inherit on, every step has fewer ticks left, so it dies out. With Inherit off, poison or fire strong enough to break tiles can keep spreading through the rock, and wetness spreads with every destroyed wet tile.
- A large radius puts many effects on screen at once, which costs performance.

## Config file

Godot Mod Loader keeps the mod's settings in `%APPDATA%\Godot\app_userdata\Coal LLC\mod_configs\der_floh-effect_spread_mod\user.json`. Besides the settings above it has:

| Key             | Default | Description                                                                                   |
| --------------- | ------- | --------------------------------------------------------------------------------------------- |
| `debug_logging` | `false` | Logs every spread to `modloader.log`. Read when the game starts, so restart it after a change |

Edit the file while the game is closed.

## Compatibility

- With the [Tick Upgrade Mod](../der_floh-tick_upgrade_mod/README.md)'s **Preserve effect duration** on, inherited ticks are scaled by the tick speed again, so spread effects can last longer than what was left on the destroyed tile.
- With the [Passive Drop Mod](../der_floh-passive_drop_mod/README.md), tiles broken by spread effects can drop passives like any other tile.

## Installation

The mod needs [Godot Mod Loader](https://github.com/NanobotZ/godot-mod-loader) (NanobotZ's fork).

- **With Vortex:** manage Coal LLC with the [Coal LLC extension for Vortex](https://github.com/Der-Floh/Vortex-CoalLLC-Support), which installs Godot Mod Loader for you, then install this mod like any other.
- **By hand:** set up Godot Mod Loader as described in the [installation guide](https://github.com/Der-Floh/coal-llc-mods#installation), then copy the mod's zip, without extracting it, into `steamapps/common/Coal LLC/Coal LLC/mods/`, the folder with `Coal LLC.exe`.

## Links

- [Changelog](changelog.md)
- [Source code](https://github.com/Der-Floh/coal-llc-mods/tree/main/src/der_floh/der_floh-effect_spread_mod)
- [Report a problem](https://github.com/Der-Floh/coal-llc-mods/issues)

> **Note:** You use mods at your own risk. Modding Coal LLC isn't officially supported, and neither the mod authors nor the game's developer Bye Bye Ocean are responsible for problems mods cause.
