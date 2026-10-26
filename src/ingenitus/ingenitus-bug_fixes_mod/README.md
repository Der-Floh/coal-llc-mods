# Bug Fixes Mod

Fixes ten bugs of the vanilla game, from the coal quota overflowing on late days to lost saves and duplicated loot. Each fix can be switched off on its own.

## Settings

Adds a **Bug Fixes** tab to the in-game settings menu: a **Mod Enabled** master switch and one toggle per fix, all on by default.

| Fix                                                         | Description                                                                                                                                                                                                                                    |
| ----------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Coal quota no longer overflows on late days                 | From day 62 the vanilla quota overflows and goes negative (about -1.1e29), so every day counts as met. The quota now keeps growing ×4 per day, from the next day start; the management screen's Upcoming Coal Quota line shows the fixed value |
| Restore a missing or corrupt save from its backup           | When the global save, the records or the hard-modifier records are missing or corrupt, vanilla loads defaults although an intact backup exists, and the next save overwrites that backup too. The backup is now put back when the game starts  |
| Resuming with Esc can no longer leave the game paused       | Resuming with Esc could leave the game paused with no menu                                                                                                                                                                                     |
| Buying can no longer leave cash below zero                  | Buying the maximum affordable employees could leave cash slightly below zero (up to -65,536 at large balances); it is now clamped to zero                                                                                                      |
| Merged or collected loot can no longer be counted twice     | A pickup that had just been merged or collected could be counted again in the same frame, so 8 coal could become 11                                                                                                                            |
| Loot cap holds during one-frame bursts (nukes, earthquakes) | The **Max Item Drops** limit never engaged when thousands of drops happen in one frame. Drops past it are now bundled for the rest of the frame without losing loot: 3000 drops make about 400 pickups at a limit of 400                       |
| Explosions reach their bottom and right edges               | Bombs and earthquakes never hit the bottom row and right column of their circle                                                                                                                                                                |
| Hide employee boxes that show x0                            | Leftovers after promotions showed "x0" employee boxes with a sell button                                                                                                                                                                       |
| Chest upgrade cards keep their own chest's multiplier       | Every chest's upgrade card took the multiplier of the chest rolled last, so a level-1 card could read x4 and a level-4 card x1                                                                                                                 |
| AOE miners also hit the tiles right next to their target    | AOE miners and flying miners skipped the row and column of their target: range 1 hit 4 of its 8 tiles, range 2 hit 16 of 24                                                                                                                    |

The save restore runs when the game starts, so switching it on or off only matters at the next launch. The other fixes apply right away. The run save itself has no backup file, so the save restore can't recover it.

## Compatibility

- Works with the [Ore Value Mod](../../der_floh/der_floh-ore_value_mod/README.md). Before 1.1.0, the first start with both installed failed to load player skins and settings.
- The [Game Limits Mod](../../der_floh/der_floh-game_limits_mod/README.md) contains the same stuck-pause fix, so while it is installed and enabled, switching off this mod's toggle doesn't bring the vanilla behaviour back. Running both is harmless.
- The explosion fix also covers blasts enlarged by the [Extra Passives Mod](../ingenitus-extra_passives_mod/README.md).

## Installation

The mod needs [Godot Mod Loader](https://github.com/NanobotZ/godot-mod-loader) (NanobotZ's fork).

- **With Vortex:** manage Coal LLC with the [Coal LLC extension for Vortex](https://github.com/Der-Floh/Vortex-CoalLLC-Support), which installs Godot Mod Loader for you, then install this mod like any other.
- **By hand:** set up Godot Mod Loader as described in the [installation guide](https://github.com/Der-Floh/coal-llc-mods#installation), then copy the mod's zip, without extracting it, into `steamapps/common/Coal LLC/Coal LLC/mods/`, the folder with `Coal LLC.exe`.

## Links

- [Changelog](changelog.md)
- [Source code](https://github.com/Der-Floh/coal-llc-mods/tree/main/src/ingenitus/ingenitus-bug_fixes_mod)
- [Report a problem](https://github.com/Der-Floh/coal-llc-mods/issues)

> **Note:** You use mods at your own risk. Modding Coal LLC isn't officially supported, and neither the mod authors nor the game's developer Bye Bye Ocean are responsible for problems mods cause.
