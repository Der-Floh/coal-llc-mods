# No Holes Mod

By **der_floh**, part of the [Coal LLC Mods](https://github.com/Der-Floh/coal-llc-mods) collection for [Coal LLC](https://store.steampowered.com/app/3361510/Coal_LLC/).

Fills the **air pockets** world generation leaves underground, such as caves, small pockets and the gaps of Sparse maps, with the plain block of their layer, so the rock below the surface is always solid. No ore is added, and the fill blocks drop nothing. The surface and chest rooms are left alone.

- The fill block follows the layer: clay, stone, ice and fire in the upper layers, then the dark, green, orange, purple, dark green, yellow, dark brown and dark blue blocks of the deep layers.
- Sparse and Sparse Sky Mine maps become solid too.
- Under the Only Clay hard modifier, holes still get the block of their real layer, not clay.
- The game doesn't save mines; it builds a new one every time, so the mod applies from the next mine you enter.

The mod has no settings tab. To turn it off, uninstall it.

## Config file

Godot Mod Loader keeps the mod's settings in `%APPDATA%\Godot\app_userdata\Coal LLC\mod_configs\der_floh-no_holes_mod\user.json`:

| Key             | Default | Description                                                                                            |
| --------------- | ------- | ------------------------------------------------------------------------------------------------------ |
| `debug_logging` | `false` | Logs how many holes were filled in each chunk. Read when the game starts, so restart it after a change |

Edit the file while the game is closed.

## Compatibility

- Works with the [Performance Mod](../der_floh-performance_mod/README.md) and its faster chunk generation.
- With the [Custom Seed Mod](../../ingenitus/ingenitus-custom_seed_mod/README.md) by Ingenitus, mines stay reproducible, but a seed builds a different mine than without this mod.

## Installation

The mod needs [Godot Mod Loader](https://github.com/NanobotZ/godot-mod-loader) (NanobotZ's fork).

- **With Vortex:** manage Coal LLC with the [Coal LLC extension for Vortex](https://github.com/Der-Floh/Vortex-CoalLLC-Support), which installs Godot Mod Loader for you, then install this mod like any other.
- **By hand:** set up Godot Mod Loader as described in the [installation guide](https://github.com/Der-Floh/coal-llc-mods#installation), then copy the mod's zip, without extracting it, into `steamapps/common/Coal LLC/Coal LLC/mods/`, the folder with `Coal LLC.exe`.

## Links

- [Changelog](changelog.md)
- [Source code](https://github.com/Der-Floh/coal-llc-mods/tree/main/src/der_floh/der_floh-no_holes_mod)
- [Report a problem](https://github.com/Der-Floh/coal-llc-mods/issues)

> **Note:** You use mods at your own risk. Modding Coal LLC isn't officially supported, and neither the mod authors nor the game's developer Bye Bye Ocean are responsible for problems mods cause.
