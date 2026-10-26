# Game Limits Mod

By **der_floh**, part of the [Coal LLC Mods](https://github.com/Der-Floh/coal-llc-mods) collection for [Coal LLC](https://store.steampowered.com/app/3361510/Coal_LLC/).

Lets you tune limits the game normally fixes: how many mortar shells fly at once, how many employees are drawn, how much of the world around you is loaded, and how far electric pickaxe chains reach. It also fixes resuming with Esc sometimes leaving the game paused with no menu.

## Settings

Adds a **Game Limits** tab to the in-game settings menu. Changes apply immediately unless noted.

| Setting     | Default | Description                                                                                                                            |
| ----------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| Mod Enabled | On      | Off restores the vanilla limits and the vanilla pause behaviour. Max Employee Entities Drawn is a game setting and stays as you set it |

### Mortar

| Setting            | Default | Range       | Description                                                                                                                             |
| ------------------ | ------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| Max Active Mortars | `1000`  | 50 to 10000 | How many mortar shells can be in the air at once (vanilla 1000). At the limit, a shot isn't fired and its damage goes to the next shell |

### Miners / Angels

| Setting                                                       | Default | Range       | Description                                                                                                                                                                         |
| ------------------------------------------------------------- | ------- | ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Max Employee Entities Drawn (takes effect on next level load) | `500`   | 50 to 10000 | How many employees are drawn. This is the game's own setting from the Gameplay tab, which only goes up to 2000; moving one slider moves the other. Applies from the next level load |

### Chunk Loading

| Setting                                       | Default | Range    | Description                                                                                                                                                                                  |
| --------------------------------------------- | ------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Chunk Load Radius (chunks around each entity) | `3`     | 1 to 100 | How many chunks are loaded around you and everything else that loads chunks: 3 loads 7×7 chunks around each, 10 loads 21×21. Only the outer, visible ring grows; full collision stays at 3×3 |
| Chunks Generated Per Frame                    | `1`     | 1 to 10  | How many new chunks are generated each frame. Higher fills the loaded area faster, but makes frames longer while it loads                                                                    |

### Electric Pickaxe

| Setting                                                  | Default | Range      | Description                                                                                                        |
| -------------------------------------------------------- | ------- | ---------- | ------------------------------------------------------------------------------------------------------------------ |
| Max Chain Reaction Tiles                                 | `500`   | 10 to 5000 | How many tiles one electric pickaxe chain can reach (vanilla 500)                                                  |
| Max Visual Arcs (0 = no visuals; does not affect damage) | `200`   | 0 to 1000  | How many tiles of a chain get an electricity arc. Vanilla draws one for every tile, so long chains show fewer arcs |

- A bigger load radius costs generation time, memory and drawing. The [Performance Mod](../der_floh-performance_mod/README.md) makes large radii and long chains much cheaper.
- Lowering Max Active Mortars doesn't remove shells the current level has already built up.
- Max Employee Entities Drawn isn't stored in the mod's config but in the game's settings, so a value above 2000 stays after you remove the mod.

## Pause fix

Resuming with Esc could leave the game paused with no menu. The mod fixes that while **Mod Enabled** is on. The [Bug Fixes Mod](../../ingenitus/ingenitus-bug_fixes_mod/README.md) by Ingenitus has the same fix; running both is harmless.

## Config file

Godot Mod Loader keeps the mod's settings in `%APPDATA%\Godot\app_userdata\Coal LLC\mod_configs\der_floh-game_limits_mod\user.json`. Besides the settings above it has:

| Key             | Default | Description                                                                                                                                                            |
| --------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `debug_logging` | `false` | Logs every shot held back at the mortar limit and, without the Performance Mod, every finished electric chain. Read when the game starts, so restart it after a change |

Edit the file while the game is closed. Values outside a slider's range are corrected the next time you open the settings menu.

## Compatibility

- The [Performance Mod](../der_floh-performance_mod/README.md) uses these settings for its faster chunk loading and electric chains, so install both together and update them together. While this mod's **Mod Enabled** is off, it uses the vanilla limits.
- With the [Pickaxe AOE Mod](../der_floh-pickaxeaoe_mod/README.md), electric chains no longer lose damage, so they only stop at **Max Chain Reaction Tiles** or at the end of the vein.

## Installation

The mod needs [Godot Mod Loader](https://github.com/NanobotZ/godot-mod-loader) (NanobotZ's fork).

- **With Vortex:** manage Coal LLC with the [Coal LLC extension for Vortex](https://github.com/Der-Floh/Vortex-CoalLLC-Support), which installs Godot Mod Loader for you, then install this mod like any other.
- **By hand:** set up Godot Mod Loader as described in the [installation guide](https://github.com/Der-Floh/coal-llc-mods#installation), then copy the mod's zip, without extracting it, into `steamapps/common/Coal LLC/Coal LLC/mods/`, the folder with `Coal LLC.exe`.

## Links

- [Changelog](changelog.md)
- [Source code](https://github.com/Der-Floh/coal-llc-mods/tree/main/src/der_floh/der_floh-game_limits_mod)
- [Report a problem](https://github.com/Der-Floh/coal-llc-mods/issues)

> **Note:** You use mods at your own risk. Modding Coal LLC isn't officially supported, and neither the mod authors nor the game's developer Bye Bye Ocean are responsible for problems mods cause.
