# Ore Value Mod

Sets a sell price **multiplier** for every ore type. Each ore is scaled on its own, relative to its vanilla price: set Coal to `1000000` to sell it for 1,000,000× its vanilla price, or leave everything at `1` for vanilla prices.

## Settings

Adds an **Ore Value** tab to the in-game settings menu. A changed multiplier applies immediately. Each ore has a number box for whole numbers from `0`, which makes the ore worthless, up to 1 quadrillion (`1e15`).

| Setting     | Default | Description                 |
| ----------- | ------- | --------------------------- |
| Mod Enabled | On      | Off uses the vanilla prices |

### Coal

| Ore  | Default |
| ---- | ------- |
| Coal | `1`     |

Under the **Coal Is Worthless** hard modifier, coal sells for 0 whatever its multiplier.

### Minerals

| Ore        | Default |
| ---------- | ------- |
| Copper Ore | `1`     |
| Iron Ore   | `1`     |
| Silver Ore | `1`     |
| Gold Ore   | `1`     |

### Gems

| Ore          | Default |
| ------------ | ------- |
| Amethyst     | `1`     |
| Sapphire     | `1`     |
| Emerald      | `1`     |
| Ruby         | `1`     |
| Diamond      | `1`     |
| Pink Diamond | `1`     |
| Spinel       | `1`     |
| Uranium      | `1`     |
| Moonstone    | `1`     |
| Onyx         | `1`     |

## Config file

Godot Mod Loader keeps the mod's settings in `%APPDATA%\Godot\app_userdata\Coal LLC\mod_configs\der_floh-ore_value_mod\user.json`. Besides the settings above it has:

| Key             | Default | Description                                                                                          |
| --------------- | ------- | ---------------------------------------------------------------------------------------------------- |
| `debug_logging` | `false` | Logs every changed price to `modloader.log`. Read when the game starts, so restart it after a change |

The file also takes fractional multipliers such as `0.5`. The number box shows them rounded, and editing the box replaces them with a whole number. Edit the file while the game is closed.

## Compatibility

- Don't install it together with the old Coal Value Mod (`der_floh-coal_value_mod`): both change ore prices, and Godot Mod Loader doesn't stop both from loading.
- The [Number Format Mod](../../ingenitus/ingenitus-number_format_mod/README.md) by Ingenitus shows the resulting huge prices more readably.
- Works with the [Bug Fixes Mod](../../ingenitus/ingenitus-bug_fixes_mod/README.md) by Ingenitus from its version 1.1.0 on.

## Installation

The mod needs [Godot Mod Loader](https://github.com/NanobotZ/godot-mod-loader) (NanobotZ's fork).

- **With Vortex:** manage Coal LLC with the [Coal LLC extension for Vortex](https://github.com/Der-Floh/Vortex-CoalLLC-Support), which installs Godot Mod Loader for you, then install this mod like any other.
- **By hand:** set up Godot Mod Loader as described in the [installation guide](https://github.com/Der-Floh/coal-llc-mods#installation), then copy the mod's zip, without extracting it, into `steamapps/common/Coal LLC/Coal LLC/mods/`, the folder with `Coal LLC.exe`.

## Links

- [Changelog](changelog.md)
- [Source code](https://github.com/Der-Floh/coal-llc-mods/tree/main/src/der_floh/der_floh-ore_value_mod)
- [Report a problem](https://github.com/Der-Floh/coal-llc-mods/issues)

> **Note:** You use mods at your own risk. Modding Coal LLC isn't officially supported, and neither the mod authors nor the game's developer Bye Bye Ocean are responsible for problems mods cause.
