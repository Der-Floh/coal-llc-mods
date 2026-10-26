# Number Format Mod

Large numbers (cash, coal, prices) show as short scientific notation like `1.23e10` instead of Godot's `1.23457e+10`. Values that round up show as `1.00e16`, never `10.00e15`. Numbers the game shows with thousands separators are unchanged.

The mod only changes how numbers are displayed: it has no settings tab and doesn't touch your save.

## Config file

Godot Mod Loader keeps the mod's settings in `%APPDATA%\Godot\app_userdata\Coal LLC\mod_configs\ingenitus-number_format_mod\user.json`:

| Key       | Default | Description                         |
| --------- | ------- | ----------------------------------- |
| `enabled` | `true`  | `false` shows numbers as in vanilla |

Edit the file while the game is closed.

## Compatibility

- Handy with the [Ore Value Mod](../../der_floh/der_floh-ore_value_mod/README.md), whose price multipliers quickly produce numbers this large.

## Installation

The mod needs [Godot Mod Loader](https://github.com/NanobotZ/godot-mod-loader) (NanobotZ's fork).

- **With Vortex:** manage Coal LLC with the [Coal LLC extension for Vortex](https://github.com/Der-Floh/Vortex-CoalLLC-Support), which installs Godot Mod Loader for you, then install this mod like any other.
- **By hand:** set up Godot Mod Loader as described in the [installation guide](https://github.com/Der-Floh/coal-llc-mods#installation), then copy the mod's zip, without extracting it, into `steamapps/common/Coal LLC/Coal LLC/mods/`, the folder with `Coal LLC.exe`.

## Links

- [Changelog](changelog.md)
- [Source code](https://github.com/Der-Floh/coal-llc-mods/tree/main/src/ingenitus/ingenitus-number_format_mod)
- [Report a problem](https://github.com/Der-Floh/coal-llc-mods/issues)

> **Note:** You use mods at your own risk. Modding Coal LLC isn't officially supported, and neither the mod authors nor the game's developer Bye Bye Ocean are responsible for problems mods cause.
