# Pickaxe AOE Mod

Makes the **electric pickaxe** and the **AOE strike** deal full damage to every tile they hit, instead of the reduced damage vanilla deals to chained and surrounding tiles.

- **Electric pickaxe:** in vanilla the chain loses 20% per tile (100%, 80%, 64%, 51% and so on). With the mod every chained tile takes 100%. The chain still only runs through touching tiles of the same block, so it now goes on until the end of the vein or the chain limit (500 tiles, adjustable in the [Game Limits Mod](../der_floh-game_limits_mod/README.md)). The tile you hit is no longer hit a second time by its own chain.
- **AOE strike:** in vanilla a strike hits its target for 100% plus a radius-2 blast for 30%, so the target takes 130% and the tiles around it 30%. With the mod the blast deals 100%, so the target and every tile around it take 100%.

The mod has no settings tab. To turn it off, uninstall it.

## Config file

Godot Mod Loader keeps the mod's settings in `%APPDATA%\Godot\app_userdata\Coal LLC\mod_configs\der_floh-pickaxeaoe_mod\user.json`:

| Key             | Default | Description                                                               |
| --------------- | ------- | ------------------------------------------------------------------------- |
| `debug_logging` | `false` | Logs every swing. Read when the game starts, so restart it after a change |

Edit the file while the game is closed.

## Compatibility

- The [Game Limits Mod](../der_floh-game_limits_mod/README.md)'s **Max Chain Reaction Tiles** sets how far the full-damage chains reach, and the [Performance Mod](../der_floh-performance_mod/README.md) makes long chains much cheaper.
- With the [Bug Fixes Mod](../../ingenitus/ingenitus-bug_fixes_mod/README.md) by Ingenitus, the AOE blast also reaches the bottom row and right column of its circle.
- garethwhite-prog's [Excavation Frenzy](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-excavation_frenzy_mod) needs this mod.

## Installation

The mod needs [Godot Mod Loader](https://github.com/NanobotZ/godot-mod-loader) (NanobotZ's fork).

- **With Vortex:** manage Coal LLC with the [Coal LLC extension for Vortex](https://github.com/Der-Floh/Vortex-CoalLLC-Support), which installs Godot Mod Loader for you, then install this mod like any other.
- **By hand:** set up Godot Mod Loader as described in the [installation guide](https://github.com/Der-Floh/coal-llc-mods#installation), then copy the mod's zip, without extracting it, into `steamapps/common/Coal LLC/Coal LLC/mods/`, the folder with `Coal LLC.exe`.

## Links

- [Changelog](changelog.md)
- [Source code](https://github.com/Der-Floh/coal-llc-mods/tree/main/src/der_floh/der_floh-pickaxeaoe_mod)
- [Report a problem](https://github.com/Der-Floh/coal-llc-mods/issues)

> **Note:** You use mods at your own risk. Modding Coal LLC isn't officially supported, and neither the mod authors nor the game's developer Bye Bye Ocean are responsible for problems mods cause.
