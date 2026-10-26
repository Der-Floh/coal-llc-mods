# Chest QoL Mod

Less fiddly chests: they open when you touch them, can loot straight to your inventory, can be taken from their protective tiles once one of them is mined, and stop offering power-up scrolls for weapons you have already outclassed.

## Settings

Adds a **Chests** tab to the in-game settings menu. Every option is on by default and applies immediately.

| Setting                                                       | Description                                                                                                                                                                                                                           |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Mod Enabled                                                   | Off restores vanilla chests                                                                                                                                                                                                           |
| Open chests when you touch them                               | Touching a chest opens it without pressing interact. Without One-Click Looting you still loot it by interacting, and the loot lands on the ground as in vanilla                                                                       |
| Loot straight to inventory on touch (needs One-Click Looting) | With the vanilla One-Click Looting upgrade owned, touching a chest loots it straight to your inventory, just like interacting does with that upgrade                                                                                  |
| Reach chests from their protective tiles once one is mined    | Every generated chest sits inside a ring of eight protective tiles. Once one of them is mined, standing on any of them counts as touching the chest; an intact ring never gives the chest away                                        |
| Replace power-up scrolls for weapons weaker than yours        | A chest's power-up scroll for a weapon whose tier is the same as or lower than one of that type in your inventory becomes a passive-upgrade card with vanilla's multiplier. Every weapon line is covered, including electric pickaxes |

Looting on touch and reaching chests from their protective tiles only work while **Open chests when you touch them** is on.

## Compatibility

- The [Passive Drop Mod](../../der_floh/der_floh-passive_drop_mod/README.md) turns chest generation off by default, so there are no chests at all until you switch its **Chest Generation** on or its **Mod Enabled** off. With its **Weapon Drops from Chests** off, every scroll is already a card and the scroll option has nothing left to do.
- [AutoPassiveChooser](https://github.com/NanobotZ/CoalLLC-AutoPassiveChooser) loots a chest as soon as one of its protective tiles is destroyed, so with it installed the protective-tile option rarely gets a chance.
- Works with the [Bug Fixes Mod](../ingenitus-bug_fixes_mod/README.md), which also fixes the multiplier of chest upgrade cards.

## Installation

The mod needs [Godot Mod Loader](https://github.com/NanobotZ/godot-mod-loader) (NanobotZ's fork).

- **With Vortex:** manage Coal LLC with the [Coal LLC extension for Vortex](https://github.com/Der-Floh/Vortex-CoalLLC-Support), which installs Godot Mod Loader for you, then install this mod like any other.
- **By hand:** set up Godot Mod Loader as described in the [installation guide](https://github.com/Der-Floh/coal-llc-mods#installation), then copy the mod's zip, without extracting it, into `steamapps/common/Coal LLC/Coal LLC/mods/`, the folder with `Coal LLC.exe`.

## Links

- [Changelog](changelog.md)
- [Source code](https://github.com/Der-Floh/coal-llc-mods/tree/main/src/ingenitus/ingenitus-chest_qol_mod)
- [Report a problem](https://github.com/Der-Floh/coal-llc-mods/issues)

> **Note:** You use mods at your own risk. Modding Coal LLC isn't officially supported, and neither the mod authors nor the game's developer Bye Bye Ocean are responsible for problems mods cause.
