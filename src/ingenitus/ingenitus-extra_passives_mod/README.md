# Extra Passives Mod

Ten new level-up passives for weapons and tools that had few or none. A passive is only offered while you hold an item it applies to (or own a vacuum), and a passive with a cap is no longer offered once it reaches it.

## Passives

Each pick adds the step below. A passive-upgrade card from a chest multiplies it, as it does for vanilla passives.

| Passive           | Per pick | Offered with                    | Cap    | Effect                                                                                                                                        |
| ----------------- | -------- | ------------------------------- | ------ | --------------------------------------------------------------------------------------------------------------------------------------------- |
| Gun Fire Rate     | +5%      | pistol, shotgun, rifle, minigun | +1300% | Shorter gun cooldown, never below 0.05 s                                                                                                      |
| Extra Projectiles | +10%     | pistol, shotgun, rifle, minigun | -      | Every 100% adds one bullet per shot; fractions add up across shots, so +50% gives one extra bullet every other shot                           |
| Bullet Pierce     | +10%     | pistol, shotgun, rifle, minigun | -      | Every 100% lets each bullet pass one more breakable block; fractions add up across shots. Unbreakable tiles and the gun's range still stop it |
| Axe Spin-Up Speed | +5%      | axe, battleaxe                  | -      | The whirl reaches full spin, and stops, faster. Top speed and damage are unchanged                                                            |
| Vacuum Range      | +5%      | any vacuum                      | -      | Longer hose                                                                                                                                   |
| Vacuum Suction    | +5%      | any vacuum                      | -      | Wider grab area at the nozzle                                                                                                                 |
| Drill Speed       | +5%      | drill                           | -      | Drills dig faster                                                                                                                             |
| Earthquake Damage | +5%      | earthquake inducer              | -      | More damage                                                                                                                                   |
| Earthquake Radius | +5%      | earthquake inducer              | +380%  | Bigger radius                                                                                                                                 |
| Bomb Radius       | +5%      | bombs, nuke                     | +1100% | Bigger blasts                                                                                                                                 |

- Bomb and earthquake blasts reach at most 48 tiles from their centre, the area loaded around the player. Small bombs get the full bonus, while the nuke (radius 40) grows to 48 at most.
- Once you have Bomb Radius, the passive bonuses panel (Tab) has a slider to dial it back, from 0 up to what you have earned. At full it follows new picks. While a Bomb Radius bonus is in use, bombs from other mods with a radius above 48 are limited to 48 too; dial the slider to 0% to avoid that.
- Every earned passive is listed in the passive bonuses panel (Tab).
- Assassins can also be offered the vanilla Wet Damage passive.
- The levels and the slider are stored in your run save and start over with a new run. Removing the mod loses them at the next save.

## Config file

Godot Mod Loader keeps the mod's settings in `%APPDATA%\Godot\app_userdata\Coal LLC\mod_configs\ingenitus-extra_passives_mod\user.json`:

| Key       | Default | Description                                                                                                                       |
| --------- | ------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `enabled` | `true`  | `false` stops the offers and the effects; earned levels stay in the save. Read when the game starts, so restart it after a change |

Edit the file while the game is closed.

## Compatibility

- [AutoPassiveChooser](https://github.com/NanobotZ/CoalLLC-AutoPassiveChooser) can prioritise and limit these passives. They only show up in its list while they can be offered, for example mid-run while you hold the item.
- Works with the [Tick Upgrade Mod](../../der_floh/der_floh-tick_upgrade_mod/README.md), whose tick-speed passives are offered alongside these.
- Works with the [Axe Glare Toggle Mod](../ingenitus-axe_glare_toggle_mod/README.md) and the [Bug Fixes Mod](../ingenitus-bug_fixes_mod/README.md), whose explosion fix also covers enlarged blasts.

## Installation

The mod needs [Godot Mod Loader](https://github.com/NanobotZ/godot-mod-loader) (NanobotZ's fork).

- **With Vortex:** manage Coal LLC with the [Coal LLC extension for Vortex](https://github.com/Der-Floh/Vortex-CoalLLC-Support), which installs Godot Mod Loader for you, then install this mod like any other.
- **By hand:** set up Godot Mod Loader as described in the [installation guide](https://github.com/Der-Floh/coal-llc-mods#installation), then copy the mod's zip, without extracting it, into `steamapps/common/Coal LLC/Coal LLC/mods/`, the folder with `Coal LLC.exe`.

## Links

- [Changelog](changelog.md)
- [Source code](https://github.com/Der-Floh/coal-llc-mods/tree/main/src/ingenitus/ingenitus-extra_passives_mod)
- [Report a problem](https://github.com/Der-Floh/coal-llc-mods/issues)

> **Note:** You use mods at your own risk. Modding Coal LLC isn't officially supported, and neither the mod authors nor the game's developer Bye Bye Ocean are responsible for problems mods cause.
