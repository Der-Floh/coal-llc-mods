# Move Speed Slider Mod

> **Credit:** Ingenitus created this mod and handed it over to me. Thank you, Ingenitus, for your work!

Adds a **Walk Speed** slider to the passive bonuses panel (Tab). Walking can be raised up to your current sprint speed and never past it: the sprint passive, the sprint slider and the speed quest reward all count. Handy with Auto Sprint, or to move at sprint pace without holding the key.

## Slider

The **Walk Speed (up to sprint)** row is always in the passive bonuses panel (Tab) while the mod is enabled; no passive is needed. Its label shows the most you can add right now: +50% without upgrades, +80% with a +20% sprint passive, +200% with the speed quest reward. Lowering the vanilla sprint slider lowers that limit too. The slider moves freely and applies immediately.

With the game's Auto Sprint setting on, you sprint by default and walk while you hold Sprint, so the slider sets that walking speed.

The value is stored in the mod config, not in your save, so it applies to every save, and removing the mod leaves your saves untouched.

## Config file

Godot Mod Loader keeps the mod's settings in `%APPDATA%\Godot\app_userdata\Coal LLC\mod_configs\ingenitus-move_speed_slider_mod\user.json`:

| Key                | Default | Description                                                                         |
| ------------------ | ------- | ----------------------------------------------------------------------------------- |
| `enabled`          | `true`  | `false` removes the slider. Read when the game starts, so restart it after a change |
| `walk_speed_bonus` | `0`     | Set by the slider: the bonus as a fraction of walking speed, so `0.5` is +50%       |

Edit the file while the game is closed.

## Installation

The mod needs [Godot Mod Loader](https://github.com/NanobotZ/godot-mod-loader) (NanobotZ's fork).

- **With Vortex:** manage Coal LLC with the [Coal LLC extension for Vortex](https://github.com/Der-Floh/Vortex-CoalLLC-Support), which installs Godot Mod Loader for you, then install this mod like any other.
- **By hand:** set up Godot Mod Loader as described in the [installation guide](https://github.com/Der-Floh/coal-llc-mods#installation), then copy the mod's zip, without extracting it, into `steamapps/common/Coal LLC/Coal LLC/mods/`, the folder with `Coal LLC.exe`.

## Links

- [Changelog](changelog.md)
- [Source code](https://github.com/Der-Floh/coal-llc-mods/tree/main/src/ingenitus/ingenitus-move_speed_slider_mod)
- [Report a problem](https://github.com/Der-Floh/coal-llc-mods/issues)

> **Note:** You use mods at your own risk. Modding Coal LLC isn't officially supported, and neither the mod authors nor the game's developer Bye Bye Ocean are responsible for problems mods cause.
