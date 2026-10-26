# Passive Drop Mod

Gives every ore type, and optionally every other block, a chance to drop a **Passive Upgrade** card when it is destroyed: the card chests give, which opens the passive chooser. Like chest loot, the card gets better deeper down. Its multiplier follows the tile's layer: ×1 in layers 0–1, ×2 in 2–4, ×3 in 5–7, ×4 in 8–11, and from ×25 up to ×144 in the deep layers 12–19.

The mod can also turn the weapon scrolls in chests into cards, switch chest generation on and off, and collect dropped cards for you.

> **Note:** By default the mod turns chest generation **off**, so mines have no chests at all until you switch **Chest Generation** on or **Mod Enabled** off.

## Settings

Adds a **Passive Drop** tab to the in-game settings menu. Changes apply immediately unless noted.

| Setting     | Default | Description                                                                    |
| ----------- | ------- | ------------------------------------------------------------------------------ |
| Mod Enabled | On      | Off stops all drops and scroll replacements and generates chests as in vanilla |

### Drop chances

Each slider sets the chance, from 0 to 100%, that a destroyed tile of that type drops a card. The defaults follow ore rarity.

| Ore            | Default |
| -------------- | ------- |
| Coal           | `1%`    |
| Copper         | `2%`    |
| Iron           | `4%`    |
| Silver         | `6%`    |
| Gold           | `8%`    |
| Amethyst       | `10%`   |
| Sapphire       | `20%`   |
| Emerald        | `30%`   |
| Ruby           | `40%`   |
| Diamond        | `50%`   |
| Pink Diamond   | `60%`   |
| Spinel         | `70%`   |
| Uranium        | `80%`   |
| Moonstone      | `90%`   |
| Onyx           | `100%`  |
| Non-Ore Blocks | `0%`    |

**Non-Ore Blocks** covers plain rock, chest walls and dungeon stone.

### Chests

| Setting                            | Default | Description                                                                                                                                 |
| ---------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| Weapon Drops from Chests           | On      | Off turns the 10-second weapon power-up scrolls that chests of level 1 to 4 can hold into Passive Upgrade cards with the chest's multiplier |
| Chest Generation (new chunks only) | Off     | On generates chest dungeons as in vanilla, in every chunk generated after the change                                                        |

### Behaviour

| Setting                       | Default | Description                                                                                                                                                                  |
| ----------------------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Auto-Collect Dropped Passives | Off     | On opens the passive chooser for each drop right away, one card per frame, instead of dropping it in the world. Together with AutoPassiveChooser no clicks are needed at all |

- Every destroyed tile can drop a card: mined by you or by employees, blown up, or broken by poison or fire. Cards from far away drop where the tile was.
- Without AutoPassiveChooser, Auto-Collect opens a chooser for every card, and you pick in each one.

## Config file

Godot Mod Loader keeps the mod's settings in `%APPDATA%\Godot\app_userdata\Coal LLC\mod_configs\der_floh-passive_drop_mod\user.json`. Besides the settings above it has:

| Key             | Default | Description                                                                                        |
| --------------- | ------- | -------------------------------------------------------------------------------------------------- |
| `debug_logging` | `false` | Logs every drop and every replaced scroll. Read when the game starts, so restart it after a change |

Edit the file while the game is closed.

## Compatibility

- [AutoPassiveChooser](https://github.com/NanobotZ/CoalLLC-AutoPassiveChooser) picks in every chooser, so cards are chosen for you whether you walk over them or Auto-Collect opens them.
- With Auto-Collect, also install the [Tick Upgrade Mod](../der_floh-tick_upgrade_mod/README.md): its passive chooser doesn't pause the game for auto-collected cards, which otherwise makes physics and the camera stutter.
- Works with the [Performance Mod](../der_floh-performance_mod/README.md) and its faster chest generation. Use its version 1.3.4 or later, which makes sure **Chest Generation** always applies.
- With **Weapon Drops from Chests** off, the [Chest QoL Mod](../../ingenitus/ingenitus-chest_qol_mod/README.md) by Ingenitus has no scrolls left to convert.
- With **Chest Generation** off and **Mod Enabled** on, the [Custom Seed Mod](../../ingenitus/ingenitus-custom_seed_mod/README.md) by Ingenitus builds mines without chests, whatever the seed.
- Tiles broken by the [Effect Spread Mod](../der_floh-effect_spread_mod/README.md)'s spreading can drop cards too.

## Installation

The mod needs [Godot Mod Loader](https://github.com/NanobotZ/godot-mod-loader) (NanobotZ's fork).

- **With Vortex:** manage Coal LLC with the [Coal LLC extension for Vortex](https://github.com/Der-Floh/Vortex-CoalLLC-Support), which installs Godot Mod Loader for you, then install this mod like any other.
- **By hand:** set up Godot Mod Loader as described in the [installation guide](https://github.com/Der-Floh/coal-llc-mods#installation), then copy the mod's zip, without extracting it, into `steamapps/common/Coal LLC/Coal LLC/mods/`, the folder with `Coal LLC.exe`.

## Links

- [Changelog](changelog.md)
- [Source code](https://github.com/Der-Floh/coal-llc-mods/tree/main/src/der_floh/der_floh-passive_drop_mod)
- [Report a problem](https://github.com/Der-Floh/coal-llc-mods/issues)

> **Note:** You use mods at your own risk. Modding Coal LLC isn't officially supported, and neither the mod authors nor the game's developer Bye Bye Ocean are responsible for problems mods cause.
