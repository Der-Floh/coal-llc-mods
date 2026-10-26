# Tick Upgrade Mod

By **der_floh**, part of the [Coal LLC Mods](https://github.com/Der-Floh/coal-llc-mods) collection for [Coal LLC](https://store.steampowered.com/app/3361510/Coal_LLC/).

Adds two level-up passives, **Poison Tick Speed** and **Fire Tick Speed**, that make poison and fire tick faster. It also keeps poison and fire **ticking on distant tiles** outside the loaded area, instead of pausing them when you walk away.

## Passives

- Each pick adds +10% tick speed. A passive-upgrade card multiplies it, as it does for vanilla passives.
- The damage per tick stays the same, but a tile ticks more often: at +100% twice as often.
- Poison Tick Speed is offered while you own a poison gun or poison staff, and Fire Tick Speed while you own a flamethrower.
- Once picked, they are listed in the passive bonuses panel (Tab), and AutoPassiveChooser can prioritise them.
- The tick speeds are saved with your run like the other passives, and a new run starts at +0%. Saves from before version 1.3.3 load at +0%.

## Settings

Adds a **Tick Upgrades** tab to the in-game settings menu. Changes apply immediately.

| Setting     | Default | Description                                                                          |
| ----------- | ------- | ------------------------------------------------------------------------------------ |
| Mod Enabled | On      | Off stops offering the passives and switches off the extra ticks and distant ticking |

### Distant Tile Ticking

| Setting                                  | Default | Description                                                                           |
| ---------------------------------------- | ------- | ------------------------------------------------------------------------------------- |
| Always tick distant (out-of-range) tiles | On      | Poison and fire keep ticking, at the boosted speed, on chunks outside the loaded area |

### Tick Speed

| Setting                                               | Default | Description                                                                                                                                                                                                                 |
| ----------------------------------------------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Preserve effect duration when tick speed is increased | On      | On: effects last as long as in vanilla but tick faster, so they deal more damage in total. Off: the same number of ticks comes faster, so the same damage in less time. Applies to poison and fire applied after the change |

- Loot from tiles that break far away drops where the tile was.
- High tick speeds with many burning or poisoned chunks around cost performance.

## Config file

Godot Mod Loader keeps the mod's settings in `%APPDATA%\Godot\app_userdata\Coal LLC\mod_configs\der_floh-tick_upgrade_mod\user.json`. Besides the settings above it has:

| Key             | Default | Description                                                                                                                                     |
| --------------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `debug_logging` | `false` | Logs every tile-effect pass and every poison application, which floods `modloader.log`. Read when the game starts, so restart it after a change |

Edit the file while the game is closed.

## Compatibility

- [AutoPassiveChooser](https://github.com/NanobotZ/CoalLLC-AutoPassiveChooser) can prioritise both passives, and its **Up to** field works for them.
- The [Passive Drop Mod](../der_floh-passive_drop_mod/README.md)'s auto-collected cards don't pause the game while this mod is enabled.
- Distant ticking works with the [Performance Mod](../der_floh-performance_mod/README.md)'s faster tile effects.
- With **Preserve effect duration** on, effects spread by the [Effect Spread Mod](../der_floh-effect_spread_mod/README.md) can last longer than what was left on the destroyed tile.
- Works with the [Extra Passives Mod](../../ingenitus/ingenitus-extra_passives_mod/README.md) by Ingenitus, whose passives are offered alongside these. Both mods save their passives with the run.

## Installation

The mod needs [Godot Mod Loader](https://github.com/NanobotZ/godot-mod-loader) (NanobotZ's fork).

- **With Vortex:** manage Coal LLC with the [Coal LLC extension for Vortex](https://github.com/Der-Floh/Vortex-CoalLLC-Support), which installs Godot Mod Loader for you, then install this mod like any other.
- **By hand:** set up Godot Mod Loader as described in the [installation guide](https://github.com/Der-Floh/coal-llc-mods#installation), then copy the mod's zip, without extracting it, into `steamapps/common/Coal LLC/Coal LLC/mods/`, the folder with `Coal LLC.exe`.

## Links

- [Changelog](changelog.md)
- [Source code](https://github.com/Der-Floh/coal-llc-mods/tree/main/src/der_floh/der_floh-tick_upgrade_mod)
- [Report a problem](https://github.com/Der-Floh/coal-llc-mods/issues)

> **Note:** You use mods at your own risk. Modding Coal LLC isn't officially supported, and neither the mod authors nor the game's developer Bye Bye Ocean are responsible for problems mods cause.
