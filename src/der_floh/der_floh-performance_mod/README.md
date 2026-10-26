# Performance Mod

Replaces some of the game's busiest code with faster versions, to cut frame-time spikes while you move through the world, while many tiles burn or are poisoned, and during long electric pickaxe chains. The mines it generates are identical to vanilla's.

- **Chunk loading:** the loaded area is only rebuilt when something that loads chunks moves into another chunk, or when the chunk load radius changes.
- **Tile effects:** idle chunks at the edge of the loaded area are skipped.
- **Chunk generation:** about 6× faster than vanilla, around 3–5 ms instead of 19–24 ms per chunk, with exactly the same terrain, sprites and chest placement. Under the Only Coal hard modifier the vanilla generation is used.
- **Tight Funnel maps:** faster layer lookup.
- **Chest generation:** chests no longer load their scene from disk one by one.
- **Electric pickaxe:** chains are tracked much faster, so long chains no longer stall a frame.

The mod has no settings tab. The chunk load radius, chunks per frame and electric chain limits come from the [Game Limits Mod](../der_floh-game_limits_mod/README.md). Without it, or while its **Mod Enabled** is off, the vanilla values apply (radius 3, one chunk per frame, chains of up to 500 tiles), and at most 200 tiles of a chain get an electricity arc.

## Config file

Godot Mod Loader keeps the mod's settings in `%APPDATA%\Godot\app_userdata\Coal LLC\mod_configs\der_floh-performance_mod\user.json`:

| Key             | Default | Description                                                                                    |
| --------------- | ------- | ---------------------------------------------------------------------------------------------- |
| `debug_logging` | `false` | Logs every rebuild of the loaded area. Read when the game starts, so restart it after a change |

Edit the file while the game is closed.

## Compatibility

- Install it together with the [Game Limits Mod](../der_floh-game_limits_mod/README.md), whose settings it uses, and update both together.
- The [No Holes Mod](../der_floh-no_holes_mod/README.md), the [Passive Drop Mod](../der_floh-passive_drop_mod/README.md) and the [Tick Upgrade Mod](../der_floh-tick_upgrade_mod/README.md) build on its chunk generation, chest generation and tile effects. This mod loads before them, so their changes always apply on top of its own.
- If you switch mods off with Godot Mod Loader's user profiles, remove this mod instead of deactivating it: while it is installed but deactivated, those three mods don't load. Vortex removes disabled mods, so it isn't affected.
- With the [Custom Seed Mod](../../ingenitus/ingenitus-custom_seed_mod/README.md) by Ingenitus, a seed builds the same mine with or without this mod.

## Installation

The mod needs [Godot Mod Loader](https://github.com/NanobotZ/godot-mod-loader) (NanobotZ's fork).

- **With Vortex:** manage Coal LLC with the [Coal LLC extension for Vortex](https://github.com/Der-Floh/Vortex-CoalLLC-Support), which installs Godot Mod Loader for you, then install this mod like any other.
- **By hand:** set up Godot Mod Loader as described in the [installation guide](https://github.com/Der-Floh/coal-llc-mods#installation), then copy the mod's zip, without extracting it, into `steamapps/common/Coal LLC/Coal LLC/mods/`, the folder with `Coal LLC.exe`.

## Links

- [Changelog](changelog.md)
- [Source code](https://github.com/Der-Floh/coal-llc-mods/tree/main/src/der_floh/der_floh-performance_mod)
- [Report a problem](https://github.com/Der-Floh/coal-llc-mods/issues)

> **Note:** You use mods at your own risk. Modding Coal LLC isn't officially supported, and neither the mod authors nor the game's developer Bye Bye Ocean are responsible for problems mods cause.
