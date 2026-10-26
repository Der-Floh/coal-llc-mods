# Custom Seed Mod

By **Ingenitus**, part of the [Coal LLC Mods](https://github.com/Der-Floh/coal-llc-mods) collection for [Coal LLC](https://store.steampowered.com/app/3361510/Coal_LLC/).

Set a **world seed** to get the same mine again. Every chunk is generated from the seed, the day and the chunk's own position, so terrain, ore layers and chest positions come out the same however you explore. Chest contents and the rest of the game, such as employees, stay random.

## Settings

Adds a **World Seed** tab to the in-game settings menu. Changes take effect from the next mining day, so changing them mid-day never leaves a seam.

| Setting                                                | Default | Description                                                                         |
| ------------------------------------------------------ | ------- | ----------------------------------------------------------------------------------- |
| Mod Enabled                                            | On      | Off generates mines as in vanilla                                                   |
| World Seed                                             | `0`     | Up to 9 digits. `0` (an empty box) gives random mines, as in vanilla                |
| Same mine every day (off = a new seeded mine each day) | Off     | On uses the same mine every day; off builds a different mine from the seed each day |

A seed only builds the same mine again when everything else the generator reads is the same too: the mine type, the hard modifiers (only coal, only clay, no chests), the level of the Shift Rock Layers upgrade, the game's Chunk Size setting and the world generation mods you use. So with **Same mine every day** on, the mine still changes once you buy Shift Rock Layers.

The seed is stored in the mod config, not in your save, so it applies to every save.

## Config file

Godot Mod Loader keeps the mod's settings in `%APPDATA%\Godot\app_userdata\Coal LLC\mod_configs\ingenitus-custom_seed_mod\user.json`. Besides the settings above it has:

| Key             | Default | Description                                               |
| --------------- | ------- | --------------------------------------------------------- |
| `debug_logging` | `false` | Logs the seed of every generated chunk to `modloader.log` |

Edit the file while the game is closed.

## Compatibility

- Works with der_floh's [Performance Mod](../../der_floh/der_floh-performance_mod/README.md) and [Game Limits Mod](../../der_floh/der_floh-game_limits_mod/README.md): chunks are seeded by their position, so the order they load in doesn't matter.
- With der_floh's [No Holes Mod](../../der_floh/der_floh-no_holes_mod/README.md) mines stay reproducible, but a seed builds a different mine than without it.
- der_floh's [Passive Drop Mod](../../der_floh/der_floh-passive_drop_mod/README.md) turns chest generation off by default: until you switch its **Chest Generation** on or its **Mod Enabled** off, mines have no chests whatever the seed.

## Installation

The mod needs [Godot Mod Loader](https://github.com/NanobotZ/godot-mod-loader) (NanobotZ's fork).

- **With Vortex:** manage Coal LLC with the [Coal LLC extension for Vortex](https://github.com/Der-Floh/Vortex-CoalLLC-Support), which installs Godot Mod Loader for you, then install this mod like any other.
- **By hand:** set up Godot Mod Loader as described in the [installation guide](https://github.com/Der-Floh/coal-llc-mods#installation), then copy the mod's zip, without extracting it, into `steamapps/common/Coal LLC/Coal LLC/mods/`, the folder with `Coal LLC.exe`.

## Links

- [Changelog](changelog.md)
- [Source code](https://github.com/Der-Floh/coal-llc-mods/tree/main/src/ingenitus/ingenitus-custom_seed_mod)
- [Report a problem](https://github.com/Der-Floh/coal-llc-mods/issues)

> **Note:** You use mods at your own risk. Modding Coal LLC isn't officially supported, and neither the mod authors nor the game's developer Bye Bye Ocean are responsible for problems mods cause.
