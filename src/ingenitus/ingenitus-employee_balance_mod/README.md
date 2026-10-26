# Employee Balance Mod

In vanilla every bomber and elementalist tier swings at the intern's mining speed (`0.5`), while miners and barbarians get faster as they rank up. This mod gives bombers and elementalists the same kind of ladder. Their bombs and elemental globs are unchanged, and employees you have already hired get the new speed too.

| Employee            | Vanilla | Modded |
| ------------------- | ------- | ------ |
| Weak Bomber         | `0.5`   | `0.6`  |
| Medium Bomber       | `0.5`   | `0.7`  |
| Strong Bomber       | `0.5`   | `0.8`  |
| Fast Bomber         | `0.5`   | `0.9`  |
| Artillery           | `0.5`   | `1.0`  |
| Weak Elementalist   | `0.5`   | `0.6`  |
| Medium Elementalist | `0.5`   | `0.8`  |
| Strong Elementalist | `0.5`   | `1.0`  |

The mod has no settings tab and doesn't touch your save.

## Config file

Godot Mod Loader keeps the mod's settings in `%APPDATA%\Godot\app_userdata\Coal LLC\mod_configs\ingenitus-employee_balance_mod\user.json`:

| Key       | Default | Description                                                                                  |
| --------- | ------- | -------------------------------------------------------------------------------------------- |
| `enabled` | `true`  | `false` restores the vanilla speeds. Read when the game starts, so restart it after a change |

Edit the file while the game is closed.

## Installation

The mod needs [Godot Mod Loader](https://github.com/NanobotZ/godot-mod-loader) (NanobotZ's fork).

- **With Vortex:** manage Coal LLC with the [Coal LLC extension for Vortex](https://github.com/Der-Floh/Vortex-CoalLLC-Support), which installs Godot Mod Loader for you, then install this mod like any other.
- **By hand:** set up Godot Mod Loader as described in the [installation guide](https://github.com/Der-Floh/coal-llc-mods#installation), then copy the mod's zip, without extracting it, into `steamapps/common/Coal LLC/Coal LLC/mods/`, the folder with `Coal LLC.exe`.

## Links

- [Changelog](changelog.md)
- [Source code](https://github.com/Der-Floh/coal-llc-mods/tree/main/src/ingenitus/ingenitus-employee_balance_mod)
- [Report a problem](https://github.com/Der-Floh/coal-llc-mods/issues)

> **Note:** You use mods at your own risk. Modding Coal LLC isn't officially supported, and neither the mod authors nor the game's developer Bye Bye Ocean are responsible for problems mods cause.
