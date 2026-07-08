# Coal LLC Mods

Collection of mods for the game [Coal LLC](https://store.steampowered.com/app/2443540/Coal_LLC/).

> **IMPORTANT:** You use mods at your own risk. I am not responsible for any issues or damage caused by using mods. This is not an official modding method yet, the game author ByeByeOcean is also not responsible for any issues or damage caused by mods.

---

## Installation

All mods require **Godot Mod Loader (GML)** by NanobotZ to be installed first:<br>
👉 [https://github.com/NanobotZ/godot-mod-loader](https://github.com/NanobotZ/godot-mod-loader)

1. Download the mod loader here (choose the version for your operating system): [https://github.com/NanobotZ/godot-mod-loader/releases/latest](https://github.com/NanobotZ/godot-mod-loader/releases/latest)

2. Extract the mod loader and copy the addons folder into both of these locations:
`C:\Program Files (x86)\Steam\steamapps\common\Coal LLC\` and 
`C:\Program Files (x86)\Steam\steamapps\common\Coal LLC\Coal LLC\`

5. In Steam, open Coal LLC's properties and add this into launch options:
`--script "addons/mod_loader/mod_loader_setup.gd"`

Once GML is set up, drop the mod `.zip` file(s) into the `mods/` folder inside your Coal LLC game directory and launch the game.

> **IMPORTANT:** For now it's a good idea to delete "mod-hooks.zip" file from the game folder each time the game updates!
>
> **Warning:** When launching the game with new mods, you may see a popup saying "New mods will be applied after a restart.", and the buttons might not work. If that happens, Alt+F4 out of the game and launch the game again.

---

## Overview

| Mod                                                                | Author   | Description                                                                             |
| ------------------------------------------------------------------ | -------- | --------------------------------------------------------------------------------------- |
| [Ore Value Mod](#ore-value-mod-der_floh-ore_value_mod)             | der_floh | Configurable sell price multiplier per ore type                                         |
| [Passive Drop Mod](#passive-drop-mod-der_floh-passive_drop_mod)    | der_floh | Configurable chance for ore (and other) tiles to drop a PassiveUpgrade on destruction   |
| [Pickaxe AOE Mod](#pickaxe-aoe-mod-der_floh-pickaxeaoe_mod)        | der_floh | Electric pickaxe and AOE ability deal full damage instead of vanilla reduced ratios     |
| [Effect Spread Mod](#effect-spread-mod-der_floh-effect_spread_mod) | der_floh | Spreads poison/fire/water ticks to nearby tiles when an affected tile is destroyed      |
| [Game Limits Mod](#game-limits-mod-der_floh-game_limits_mod)       | der_floh | Tune performance-related caps (mortars, chunk loading, electric chain) via settings tab |
| [Performance Mod](#performance-mod-der_floh-performance_mod)       | der_floh | Optimised chunk loading, tile effects, and level generation to reduce frame time spikes |
| [No Holes Mod](#no-holes-mod-der_floh-no_holes_mod)                | der_floh | Fills air pockets in world generation so underground rock is always solid               |
| [AutoPassiveChooser](#other-mods-not-by-me)                        | NanobotZ | Automatically selects passives on level-up based on a configurable priority list        |

---

## Mods by me

### Ore Value Mod (`der_floh-ore_value_mod`)

Configurable sell price **multiplier** for every ore type. Each ore can be scaled independently relative to its vanilla price - set Coal to `1000000` to make it sell for 1,000,000x vanilla, or leave everything at `1` for pure vanilla prices.

> **Note:** The value updates at the beginning of each new day.

Adds an **Ore Value** tab to the in-game settings menu with a number input per ore.

#### Coal

| Option | Default | Description                    |
| ------ | ------- | ------------------------------ |
| Coal   | `1`     | Sell price multiplier for Coal |

#### Minerals

| Option     | Default | Description                          |
| ---------- | ------- | ------------------------------------ |
| Copper Ore | `1`     | Sell price multiplier for Copper Ore |
| Iron Ore   | `1`     | Sell price multiplier for Iron Ore   |
| Silver Ore | `1`     | Sell price multiplier for Silver Ore |
| Gold Ore   | `1`     | Sell price multiplier for Gold Ore   |

#### Gems

| Option       | Default | Description                            |
| ------------ | ------- | -------------------------------------- |
| Amethyst     | `1`     | Sell price multiplier for Amethyst     |
| Sapphire     | `1`     | Sell price multiplier for Sapphire     |
| Emerald      | `1`     | Sell price multiplier for Emerald      |
| Ruby         | `1`     | Sell price multiplier for Ruby         |
| Diamond      | `1`     | Sell price multiplier for Diamond      |
| Pink Diamond | `1`     | Sell price multiplier for Pink Diamond |
| Spinel       | `1`     | Sell price multiplier for Spinel       |
| Uranium      | `1`     | Sell price multiplier for Uranium      |
| Moonstone    | `1`     | Sell price multiplier for Moonstone    |
| Onyx         | `1`     | Sell price multiplier for Onyx         |

---

### Passive Drop Mod (`der_floh-passive_drop_mod`)

Adds a configurable chance for each **ore type** (and optionally any block) to drop a **PassiveUpgrade** scroll when destroyed. The **quality** of the dropped passive scales with the layer depth of the destroyed tile — just like vanilla chests give better loot deeper down.

Adds a **Passive Drop** tab to the in-game settings menu with a slider (0–100 %) per ore type.

> **Optional:** Install [AutoPassiveChooser](https://github.com/NanobotZ/CoalLLC-AutoPassiveChooser) alongside this mod and enable **Auto-Collect Dropped Passives** to have the passive chooser trigger instantly on each drop and auto-select the best option without any player interaction.

#### Drop Chances

Individual sliders for each ore type. Defaults reflect ore rarity:

| Ore            | Default |
| -------------- | ------- |
| Coal           | `1 %`   |
| Copper         | `2 %`   |
| Iron           | `4 %`   |
| Silver         | `6 %`   |
| Gold           | `8 %`   |
| Amethyst       | `10 %`  |
| Sapphire       | `20 %`  |
| Emerald        | `30 %`  |
| Ruby           | `40 %`  |
| Diamond        | `50 %`  |
| Pink Diamond   | `60 %`  |
| Spinel         | `70 %`  |
| Uranium        | `80 %`  |
| Moonstone      | `90 %`  |
| Onyx           | `100 %` |
| Non-Ore Blocks | `0 %`   |

#### Chests

| Option                   | Default | Description                                                                           |
| ------------------------ | ------- | ------------------------------------------------------------------------------------- |
| Weapon Drops from Chests | `true`  | When disabled, weapon-scroll chest drops are replaced with a passive upgrade          |
| Chest Generation         | `false` | When enabled, chest dungeons are generated normally (takes effect on next level load) |

#### Behaviour

| Option                        | Default | Description                                                                                                                                                         |
| ----------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Auto-Collect Dropped Passives | `false` | When enabled, triggers the passive chooser screen immediately on drop instead of spawning a world item; pairs with AutoPassiveChooser for fully automatic selection |

---

### Pickaxe AOE Mod (`der_floh-pickaxeaoe_mod`)

Makes the **electric pickaxe** and the **AOE ability** deal full damage to every tile they hit, instead of the reduced ratios vanilla applies to chained/surrounding tiles.

- Electric pickaxe: removes the per-step chain falloff (vanilla: ×0.8 per step)
- AOE ability: removes the area damage reduction (vanilla: ×0.3)

No configuration options.

---

### Effect Spread Mod (`der_floh-effect_spread_mod`)

When a tile that has **poison**, **fire**, or **water** ticks remaining is destroyed, those effects spread to nearby tiles in a configurable radius - so you don't waste pre-applied effects.

Adds an **Effect Spread** tab to the in-game settings menu.

| Option        | Default | Description                                                                      |
| ------------- | ------- | -------------------------------------------------------------------------------- |
| Spread Radius | `3`     | How many tiles away the effect can spread                                        |
| Inherit Ticks | `true`  | If enabled, spread tiles get the same remaining tick count as the destroyed tile |
| Fresh Ticks   | `10`    | Tick count assigned to spread tiles when Inherit Ticks is disabled               |

---

### Game Limits Mod (`der_floh-game_limits_mod`)

Adds a **Game Limits** tab to the in-game settings menu, letting you tune performance-related caps without editing files.

| Option            | Default | Description                                                                |
| ----------------- | ------- | -------------------------------------------------------------------------- |
| Max Mortars       | `1000`  | Maximum number of mortar entities active at once                           |
| Chunk Load Radius | `3`     | How many chunks around the player are loaded                               |
| Chunks Per Frame  | `1`     | How many chunks are loaded each frame (higher = faster load, more stutter) |

> **Note:** The chunk loading settings are superseded by the Performance Mod (see below) if both are installed. The Performance Mod reads the Game Limits config automatically, so install both together for the full effect.

---

### Performance Mod (`der_floh-performance_mod`)

Replaces the vanilla chunk loading and tile effect processing with optimised implementations. Reduces frame time spikes when moving through the world or when many tile effects are active.

- Replaces `load_chunks` with a more efficient version
- Replaces `apply_tile_effects` with a more efficient version
- Also replaces `generate_chunk`, `lvl_from_global_pos_*`, and `generate_chests`
- Automatically reads **Game Limits Mod** config (chunk load radius, chunks per frame) if that mod is also installed

No additional configuration options - configure chunk behaviour via the Game Limits Mod.

---

### No Holes Mod (`der_floh-no_holes_mod`)

Fills **air pockets** that vanilla world generation leaves behind. Runs a post-processing pass after each chunk is generated and fills any remaining empty underground tiles with the correct background material for their depth.

No configuration options. To disable, uninstall the mod.

> **Note:** Only affects newly generated chunks. Existing saves are unaffected until you enter a previously unloaded area.

---

## Other Mods (not by me)

These mods are not part of this repository but are listed here regardless.

| Mod                                                                          | Author   | Description                                                                                                                                                 |
| ---------------------------------------------------------------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [AutoPassiveChooser](https://github.com/NanobotZ/CoalLLC-AutoPassiveChooser) | NanobotZ | Automatically selects passives on level-up based on a configurable priority list, so you never have to click through the passive selection screen manually. |
