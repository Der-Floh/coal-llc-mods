# Coal LLC Mods

Collection of mods for the game [Coal LLC](https://store.steampowered.com/app/3361510/Coal_LLC/).

> **IMPORTANT:** You use mods at your own risk. I am not responsible for any issues or damage caused by using mods. This is not an official modding method yet, the game author ByeByeOcean is also not responsible for any issues or damage caused by mods.

---

## Installation

All mods require **Godot Mod Loader (GML)** by NanobotZ to be installed first:<br>
👉 [https://github.com/NanobotZ/godot-mod-loader](https://github.com/NanobotZ/godot-mod-loader)

1. Download the mod loader here (choose the version for your operating system): [https://github.com/NanobotZ/godot-mod-loader/releases/latest](https://github.com/NanobotZ/godot-mod-loader/releases/latest)

2. Extract the mod loader and copy the addons folder into both of these locations:
`C:\Program Files (x86)\Steam\steamapps\common\Coal LLC\` and `C:\Program Files (x86)\Steam\steamapps\common\Coal LLC\Coal LLC\`

3. In Steam, open Coal LLC's properties and add this into launch options:
`--script "addons/mod_loader/mod_loader_setup.gd"`

Once GML is set up, drop the mod `.zip` file(s) into the `mods/` folder inside your Coal LLC game directory and launch the game (do not extract the zip).

> **IMPORTANT:** For now it's a good idea to delete "mod-hooks.zip" file from the game folder each time the game updates!
>
> **Warning:** When launching the game with new mods, you may see a popup saying "New mods will be applied after a restart.", and the buttons might not work. If that happens, Alt+F4 out of the game and launch the game again.

---

## Overview

Every mod in this repository has its own README with all its settings, linked from its heading below.

| Mod                                                                | Author   | Description                                                                             |
| ------------------------------------------------------------------ | -------- | --------------------------------------------------------------------------------------- |
| [Ore Value Mod](#ore-value-mod-der_floh-ore_value_mod)             | der_floh | Configurable sell price multiplier per ore type                                         |
| [Passive Drop Mod](#passive-drop-mod-der_floh-passive_drop_mod)    | der_floh | Configurable chance for ore (and other) tiles to drop a PassiveUpgrade on destruction   |
| [Pickaxe AOE Mod](#pickaxe-aoe-mod-der_floh-pickaxeaoe_mod)        | der_floh | Electric pickaxe and AOE ability deal full damage instead of vanilla reduced ratios     |
| [Effect Spread Mod](#effect-spread-mod-der_floh-effect_spread_mod) | der_floh | Spreads poison, fire and wetness to nearby tiles when an affected tile is destroyed     |
| [Game Limits Mod](#game-limits-mod-der_floh-game_limits_mod)       | der_floh | Tune performance-related caps (mortars, chunk loading, electric chain) via settings tab |
| [Performance Mod](#performance-mod-der_floh-performance_mod)       | der_floh | Optimised chunk loading, tile effects, and level generation to reduce frame time spikes |
| [No Holes Mod](#no-holes-mod-der_floh-no_holes_mod)                | der_floh | Fills air pockets in world generation so underground rock is always solid               |
| [Tick Upgrade Mod](#tick-upgrade-mod-der_floh-tick_upgrade_mod)    | der_floh | Passives that speed up poison/fire ticking; effects keep ticking on unloaded tiles      |
| [Custom Seed Mod](#custom-seed-mod-ingenitus-custom_seed_mod)      | Ingenitus | World seed for reproducible mines, independent of exploration order                    |
| [Axe Glare Toggle Mod](#axe-glare-toggle-mod-ingenitus-axe_glare_toggle_mod) | Ingenitus | Hide the axe/battleaxe full-spin glare particles                                |
| [Bug Fixes Mod](#bug-fixes-mod-ingenitus-bug_fixes_mod)            | Ingenitus | Fixes quota overflow, save loss, stuck pause, loot duplication and more (each toggleable) |
| [Chest QoL Mod](#chest-qol-mod-ingenitus-chest_qol_mod)            | Ingenitus | Open/loot chests on touch, reach them from their protective tiles, no outclassed scrolls |
| [Number Format Mod](#number-format-mod-ingenitus-number_format_mod) | Ingenitus | Large numbers as `1.23e10` instead of `1.23457e+10`                                   |
| [Employee Balance Mod](#employee-balance-mod-ingenitus-employee_balance_mod) | Ingenitus | Bomber and elementalist tiers mine faster as they rank up                   |
| [Extra Passives Mod](#extra-passives-mod-ingenitus-extra_passives_mod) | Ingenitus | Ten new passives for guns, axes, vacuum, drill, earthquake and bombs              |
| [Move Speed Slider Mod](#move-speed-slider-mod-ingenitus-move_speed_slider_mod) | Ingenitus | Walk Speed slider (Tab) that can raise walking up to sprint speed                  |
| [AutoPassiveChooser](#other-mods-not-by-me)                        | NanobotZ | Automatically selects passives on level-up based on a configurable priority list        |
| [garethwhite-prog's mods](#other-mods-not-by-me)                   | garethwhite-prog | 26 mods: weapons, explosives, employees, shop upgrades, utilities and more              |

---

## Mods by me

### [Ore Value Mod](src/der_floh/der_floh-ore_value_mod/README.md) (`der_floh-ore_value_mod`)

Configurable sell price **multiplier** for every ore type. Each ore can be scaled independently relative to its vanilla price - set Coal to `1000000` to make it sell for 1,000,000x vanilla, or leave everything at `1` for pure vanilla prices.

> **Note:** A changed multiplier applies immediately. Under the **Coal Is Worthless** hard modifier, coal sells for 0 whatever its multiplier.

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

### [Passive Drop Mod](src/der_floh/der_floh-passive_drop_mod/README.md) (`der_floh-passive_drop_mod`)

Adds a configurable chance for each **ore type** (and optionally any block) to drop a **PassiveUpgrade** scroll when destroyed. The **quality** of the dropped passive scales with the layer depth of the destroyed tile — just like vanilla chests give better loot deeper down.

Adds a **Passive Drop** tab to the in-game settings menu with a slider (0–100 %) per ore type.

> **Note:** By default the mod turns chest generation off, so mines have no chests at all until you switch **Chest Generation** on or **Mod Enabled** off.

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
| Chest Generation         | `false` | When enabled, chest dungeons are generated normally in every newly generated chunk    |

#### Behaviour

| Option                        | Default | Description                                                                                                                                                         |
| ----------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Auto-Collect Dropped Passives | `false` | When enabled, triggers the passive chooser screen immediately on drop instead of spawning a world item; pairs with AutoPassiveChooser for fully automatic selection |

---

### [Pickaxe AOE Mod](src/der_floh/der_floh-pickaxeaoe_mod/README.md) (`der_floh-pickaxeaoe_mod`)

Makes the **electric pickaxe** and the **AOE ability** deal full damage to every tile they hit, instead of the reduced ratios vanilla applies to chained/surrounding tiles.

- Electric pickaxe: removes the per-step chain falloff (vanilla: ×0.8 per step)
- AOE ability: removes the area damage reduction (vanilla: ×0.3)

No configuration options.

---

### [Effect Spread Mod](src/der_floh/der_floh-effect_spread_mod/README.md) (`der_floh-effect_spread_mod`)

When a tile that still has **poison** or **fire** ticks left, or is **wet**, is destroyed, those effects spread to the breakable tiles in a configurable square around it - so you don't waste pre-applied effects.

Adds an **Effect Spread** tab to the in-game settings menu.

| Option        | Default | Description                                                                      |
| ------------- | ------- | -------------------------------------------------------------------------------- |
| Spread Radius | `3`     | How many tiles away the effect can spread                                        |
| Inherit Ticks | `true`  | If enabled, spread tiles get the same remaining tick count as the destroyed tile |
| Fresh Ticks   | `10`    | Tick count assigned to spread tiles when Inherit Ticks is disabled               |

---

### [Game Limits Mod](src/der_floh/der_floh-game_limits_mod/README.md) (`der_floh-game_limits_mod`)

Adds a **Game Limits** tab to the in-game settings menu, letting you tune performance-related caps without editing files. It also fixes resuming with Esc sometimes leaving the game paused with no menu.

| Option                      | Default | Description                                                                                 |
| --------------------------- | ------- | ------------------------------------------------------------------------------------------- |
| Max Active Mortars          | `1000`  | Maximum number of mortar shells active at once (50 to 10000)                                |
| Max Employee Entities Drawn | `500`   | The game's own employee draw limit from the Gameplay tab, raised to up to 10000             |
| Chunk Load Radius           | `3`     | How many chunks around you and every other chunk loader are loaded (1 to 100)               |
| Chunks Generated Per Frame  | `1`     | How many chunks are generated each frame (higher = faster load, more stutter; 1 to 10)      |
| Max Chain Reaction Tiles    | `500`   | How many tiles one electric pickaxe chain can reach (10 to 5000)                            |
| Max Visual Arcs             | `200`   | How many tiles of a chain get an electricity arc; doesn't affect damage (0 to 1000)          |

> **Note:** The Performance Mod (see below) uses these settings for its faster chunk loading and electric chains, so install both together for the full effect and update them together.

---

### [Performance Mod](src/der_floh/der_floh-performance_mod/README.md) (`der_floh-performance_mod`)

Replaces the vanilla chunk loading and tile effect processing with optimised implementations. Reduces frame time spikes when moving through the world or when many tile effects are active.

- Replaces `load_chunks` with a more efficient version
- Replaces `apply_tile_effects` with a more efficient version
- Also replaces `generate_chunk` (about 6x faster, with identical terrain), `lvl_from_global_pos_TIGHTFUNNEL` and `generate_chests`
- Speeds up electric pickaxe chains
- Uses the **Game Limits Mod** settings (chunk load radius, chunks per frame, electric chain limits) while that mod is installed and enabled, and the vanilla values otherwise
- Loads before the No Holes, Passive Drop and Tick Upgrade mods, so their changes apply on top of its own

No additional configuration options - configure chunk behaviour via the Game Limits Mod.

---

### [No Holes Mod](src/der_floh/der_floh-no_holes_mod/README.md) (`der_floh-no_holes_mod`)

Fills **air pockets** that vanilla world generation leaves behind. Runs a post-processing pass after each chunk is generated and fills any remaining empty underground tiles with the correct background material for their depth.

No configuration options. To disable, uninstall the mod.

> **Note:** The game doesn't save mines; it builds a new one every time, so the mod applies from the next mine you enter.

---

### [Tick Upgrade Mod](src/der_floh/der_floh-tick_upgrade_mod/README.md) (`der_floh-tick_upgrade_mod`)

Adds two level-up passives, **Poison Tick Speed** and **Fire Tick Speed**, each adding +10 % to its tick rate per level. They are offered while you have a poison gun or poison staff (poison) or a flamethrower (fire), are saved with your run, show up in the passive bonuses panel (Tab), and can be prioritised in AutoPassiveChooser.

Also keeps poison and fire **ticking on distant tiles** outside the loaded area, instead of pausing them when you walk away.

Adds a **Tick Upgrades** tab to the in-game settings menu.

| Option                    | Default | Description                                                                                    |
| ------------------------- | ------- | ---------------------------------------------------------------------------------------------- |
| Always Tick Distant Tiles | `true`  | Poison and fire keep ticking on out-of-range (unloaded) chunks                                 |
| Preserve Effect Duration  | `true`  | Scales the stored tick count with the tick speed, so effects tick faster but last just as long |

---

## Contributed Mods

### [Custom Seed Mod](src/ingenitus/ingenitus-custom_seed_mod/README.md) (`ingenitus-custom_seed_mod`)

Set a **world seed** to get the same mine again. Every chunk is generated from the seed, the day and the chunk's own position, so terrain, ore layers and chests come out identical however you explore. The rest of gameplay (loot rolls, employees, ...) stays random.

Adds a **World Seed** tab to the in-game settings menu.

| Option               | Default | Description                                                            |
| -------------------- | ------- | ---------------------------------------------------------------------- |
| World Seed           | `0`     | `0` = random (vanilla); any other number gives a reproducible mine     |
| Same mine every day  | `false` | When enabled, every day uses the same mine instead of a new seeded one |

> **Note:** Takes effect from the next mining day.

---

### [Axe Glare Toggle Mod](src/ingenitus/ingenitus-axe_glare_toggle_mod/README.md) (`ingenitus-axe_glare_toggle_mod`)

Hides the **glare particles** the axe and battleaxe whirl emits at full spin, which can cover the tiles you are mining. Spin, movement and damage are unchanged.

Adds an **Axe Glare** tab to the in-game settings menu.

| Option     | Default | Description                                  |
| ---------- | ------- | -------------------------------------------- |
| Show glare | `false` | Turn the glare back on without removing the mod |

---

### [Bug Fixes Mod](src/ingenitus/ingenitus-bug_fixes_mod/README.md) (`ingenitus-bug_fixes_mod`)

Fixes vanilla bugs. Each fix can be switched off on its own in the **Bug Fixes** tab of the in-game settings menu.

| Fix                   | What goes wrong in vanilla                                                                      |
| --------------------- | ----------------------------------------------------------------------------------------------- |
| Coal quota overflow   | From day 62 the coal quota goes negative (integer overflow)                                     |
| Save restore          | A missing or corrupt save loads defaults although an intact backup exists, then the backup is overwritten too |
| Stuck pause           | Resuming with Esc can leave the game paused with no menu                                        |
| Negative cash         | Buying the maximum affordable employees can leave cash below zero                               |
| Loot duplication      | Loot merged or collected in the same frame can be counted twice                                 |
| Loot cap during bursts| Nukes and earthquakes spawn thousands of pickups because the loot cap never engages within a frame |
| Explosion edges       | Explosions never reach the bottom row and right column of their circle                          |
| x0 employee boxes     | Float leftovers after promotions show "x0" boxes with a sell button                             |
| Upgrade-card multiplier | A chest's upgrade card takes the multiplier of whichever chest was rolled last                |
| AOE miner gap         | AOE miners never hit the tiles directly beside their target (4 of 8 tiles at range 1)           |

---

### [Chest QoL Mod](src/ingenitus/ingenitus-chest_qol_mod/README.md) (`ingenitus-chest_qol_mod`)

Less fiddly chests. Adds a **Chests** tab to the in-game settings menu.

| Option                   | Default | Description                                                                                       |
| ------------------------ | ------- | ------------------------------------------------------------------------------------------------- |
| Open on touch            | `true`  | Touching a chest opens it without pressing interact                                              |
| Loot on touch            | `true`  | With One-Click Looting owned, touching a chest loots it straight to your inventory                |
| Protective-ring reach    | `true`  | Once one of a chest's eight protective tiles is mined, standing on any of them takes the chest    |
| No outclassed scrolls    | `true`  | Power-up scrolls for weapons no stronger than one you own become passive-upgrade cards            |

---

### [Number Format Mod](src/ingenitus/ingenitus-number_format_mod/README.md) (`ingenitus-number_format_mod`)

Large numbers (cash, coal, prices) show as short scientific notation like `1.23e10` instead of Godot's `1.23457e+10`. Numbers shown with thousands separators are unchanged.

No configuration options besides `enabled` in the config file.

---

### [Employee Balance Mod](src/ingenitus/ingenitus-employee_balance_mod/README.md) (`ingenitus-employee_balance_mod`)

In vanilla every bomber and elementalist tier swings at the intern's mining speed (`0.5`), while miners and barbarians speed up with tier. This mod gives them the same kind of ladder. Their bombs and elemental globs are unchanged.

| Employee | Vanilla | Modded |
| -------- | ------- | ------ |
| Weak / Medium / Strong / Fast Bomber | `0.5` | `0.6` / `0.7` / `0.8` / `0.9` |
| Artillery | `0.5` | `1.0` |
| Weak / Medium / Strong Elementalist | `0.5` | `0.6` / `0.8` / `1.0` |

No configuration options besides `enabled` in the config file.

---

### [Extra Passives Mod](src/ingenitus/ingenitus-extra_passives_mod/README.md) (`ingenitus-extra_passives_mod`)

Ten new level-up passives for weapons and tools that had few or none. A passive is only offered while you own an item it applies to (or a vacuum), and a passive with a cap is no longer offered once it reaches it.

| Passive           | Offered with                     | Effect                                                              |
| ----------------- | -------------------------------- | ------------------------------------------------------------------- |
| Gun Fire Rate     | pistol, shotgun, rifle, minigun  | Shorter gun cooldown (never below 0.05 s)                          |
| Extra Projectiles | guns                             | Extra bullets per shot                                             |
| Bullet Pierce     | guns                             | Bullets pass through extra breakable blocks                        |
| Axe Spin-Up Speed | axe, battleaxe                   | Reaches full spin faster                                           |
| Vacuum Range      | a vacuum                         | Longer hose                                                        |
| Vacuum Suction    | a vacuum                         | Wider grab area                                                    |
| Drill Speed       | drill                            | Drills dig faster                                                  |
| Earthquake Damage | earthquake inducer               | More damage                                                        |
| Earthquake Radius | earthquake inducer               | Bigger radius                                                      |
| Bomb Radius       | bombs, nuke                      | Bigger blasts, with a dial-back slider in the passive bonuses panel |

All bomb and earthquake blasts are limited to 48 tiles (the loaded area around the player). Assassins can also be offered Wet Damage. Works with AutoPassiveChooser and the Tick Upgrade Mod.

---

### [Move Speed Slider Mod](src/ingenitus/ingenitus-move_speed_slider_mod/README.md) (`ingenitus-move_speed_slider_mod`)

Adds a **Walk Speed** slider to the passive bonuses panel (Tab). Walking can be raised up to your current sprint speed and never past it: the sprint passive, the sprint slider and the speed quest reward all count. Handy with auto-sprint, or to move at sprint pace without holding the key.

The value is stored in the mod config (`walk_speed_bonus`, set by the slider), not in your save, so removing the mod leaves saves untouched. Besides that, only `enabled` in the config file.

---

## Other Mods (not by me)

These mods are not part of this repository but are listed here regardless.

garethwhite-prog's mods come from [garethwhite-prog/coal-llc-mods](https://github.com/garethwhite-prog/coal-llc-mods); the ready-to-use zips are in its [`mods/`](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods) folder.

| Mod                                                                                                                                     | Author           | Description                                                                                                                                                 |
| --------------------------------------------------------------------------------------------------------------------------------------- | ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [AutoPassiveChooser](https://github.com/NanobotZ/CoalLLC-AutoPassiveChooser)                                                            | NanobotZ         | Automatically selects passives on level-up based on a configurable priority list, so you never have to click through the passive selection screen manually. |
| [Bouncing Grenade Arsenal](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-grenade_mod)                | garethwhite-prog | 15 tiers of grenades that bounce off walls and explode on a timed fuse                                                                                      |
| [Buyable Vacuums](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-buyable_vacuums_mod)                 | garethwhite-prog | Vacuum quest upgrades can also be bought in the Bonus shop; adds vacuum levels 5 to 8 (up to 600 tiles)                                                     |
| [Career Leaderboard](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-leaderboard_mod)                  | garethwhite-prog | All-time records and quest rewards for collectors, mortars, combat and wealth, shown in the settings menu                                                   |
| [Cosmic Collectors](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-more_collectors_mod)               | garethwhite-prog | 4 higher-tier Collector drones with more flight speed and capacity; needs Mod Settings System                                                               |
| [Dual Multipliers](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-dual_multipliers_mod)               | garethwhite-prog | Second scaling multipliers for drill speed, axe speed and gun fire rate, for stronger late-game scaling                                                     |
| [Elemental Transmutation](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-elemental_transmutation_mod) | garethwhite-prog | Breaking a burning tile pays 35 cash, a poisoned (corroded) one 15                                                                                          |
| [Excavation Frenzy](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-excavation_frenzy_mod)             | garethwhite-prog | Mining combo that speeds up movement and swings and triggers shockwaves; needs [Pickaxe AOE Mod](#pickaxe-aoe-mod-der_floh-pickaxeaoe_mod)                  |
| [Executive Employees](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-more_employees_mod)              | garethwhite-prog | 4 executive Miner tiers above Senior VP, up to Titan Miner; needs Mod Settings System                                                                       |
| [High-Yield Drills](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-more_drills_mod)                   | garethwhite-prog | Drill tiers 5 to 10, up to 50 billion damage                                                                                                                |
| [Hydrogen Bomb](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-hydrogen_bomb_mod)                     | garethwhite-prog | 15 tiers of Hydrogen Bombs (Shoddy to Onyx) with huge blast radii for clearing caverns                                                                      |
| [InfiniPlatform](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-infini_platform_mod)                  | garethwhite-prog | Platform that extends left and right across gaps until it hits a wall (up to 200 blocks)                                                                    |
| [Martial Legends](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-martial_legends_mod)                 | garethwhite-prog | Martial Artist gloves and kicks themed after Mike Tyson, Jean-Claude Van Damme and Chuck Norris                                                             |
| [Mod Settings System](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-mod_settings_mod)                | garethwhite-prog | Adds a "Gareth Mods" settings tab with toggles and sliders for these mods                                                                                   |
| [More Inventory Slots](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-more_inventory_slots_mod)       | garethwhite-prog | Inventory slot upgrades 4 to 10 (+20 up to +250 slots)                                                                                                      |
| [More Inventory Stacks](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-more_inventory_stacks_mod)     | garethwhite-prog | Stack size upgrades 7 to 16 for very large item counts                                                                                                      |
| [More Layer Shifts](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-more_layer_shifts_mod)             | garethwhite-prog | Shift Rock Layers upgrades 6 to 12, bringing deeper ores within reach                                                                                       |
| [More Nukes](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-more_nukes_mod)                           | garethwhite-prog | 15 tiers of Tactical Nukes (Shoddy to Onyx)                                                                                                                 |
| [More Vacuum Quests](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-more_vacuum_quests_mod)           | garethwhite-prog | Continues the vacuum questline past Diamond with Uranium, Moonstone, Onyx and Abyssal upgrades                                                              |
| [Mortar Gun Arsenal](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-more_mortars_mod)                 | garethwhite-prog | Mortar Gun tiers 6 to 10, up to 500 billion damage                                                                                                          |
| [Neutron Bomb](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-neutron_bomb_mod)                       | garethwhite-prog | 15 tiers of Neutron Bombs (Shoddy to Onyx) with small, extremely strong blasts that break bedrock                                                           |
| [Plasma Raygun](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-plasma_raygun_mod)                     | garethwhite-prog | Right-click plasma beam that cuts through several layers of rock                                                                                            |
| [Prospector's Beacon](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-prospectors_beacon_mod)          | garethwhite-prog | Every 4.5 seconds a pulse deals a little damage to a random tile just below you                                                                             |
| [Seismic Hazards](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-seismic_hazards_mod)                 | garethwhite-prog | Digging out a tile with open space on both sides can make the ceiling above it cave in                                                                      |
| [Tank Arsenal](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-tank_arsenal_mod)                       | garethwhite-prog | 45 Incendiary, Caustic and Depleted Uranium tanks for the Tanker, with chest drops                                                                          |
| [Vacuum Collector Depot](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-vacuum_depot_mod)             | garethwhite-prog | Collectors unload at the vacuum nozzle instead of the surface when it is closer                                                                             |
| [Weapon Stacker](https://github.com/garethwhite-prog/coal-llc-mods/tree/main/mods-unpacked/gareth-weapon_stacker_mod)                   | garethwhite-prog | Miniguns and water guns get stronger the more of them you stack                                                                                             |

---

## Building from source

[`build/build.ps1`](build/build.ps1) packs every mod in `src/<author>/<mod>/` into `out/<author>/<namespace>-<name>-<version>.zip`, ready to drop into the game's `mods/` folder, and writes the Nexus Mods descriptions to `out/nexus/` (see below). [`build/validate.ps1`](build/validate.ps1) then checks that every zip is in the folder of its mod's author, matches its source folder and has the layout and manifest Godot Mod Loader expects.

```powershell
./build/build.ps1
./build/validate.ps1
```

Both work with PowerShell 7 (`pwsh`) on Windows, Linux and macOS, and with the Windows PowerShell 5.1 that ships with Windows. Pass `-OutputDirectory <folder>` to build somewhere else (the author folders and `nexus/` go inside it, and older zips of the same mod there are replaced) and `-ZipDirectory <folder>` to validate that folder. Validation fails for a zip outside its author's folder, such as one an older build left directly in `out/`; delete it. If Windows PowerShell refuses to run scripts, start it with `powershell -ExecutionPolicy Bypass -File build\build.ps1`.

In VS Code, **Ctrl+Shift+B** runs the build, and **Tasks: Run Test Task** builds and then validates.

GitHub runs both scripts on every push to `main` and every pull request. When a release is published, [`publish.yml`](.github/workflows/publish.yml) runs them again and attaches every zip to the release, attested. My mods, those in `out/der_floh/`, also go to their Nexus Mods page when [`.github/nexus-mods.json`](.github/nexus-mods.json) gives them a file id, unless Nexus Mods already has that version; prereleases only get the GitHub release.

Every mod folder has a `README.md`, which is packed into the zip like the mod's other files. Images for a mod's page go in its `media/` folder, which the build leaves out of the zip. [`build/nexus-descriptions.ps1`](build/nexus-descriptions.ps1) converts the README of every mod in `.github/nexus-mods.json` into the BBCode Nexus Mods descriptions use, as `out/nexus/<namespace>-<name>.txt`: headings become sizes, tables become lists, and relative links point to the file on GitHub. Paste a description into the mod page's description editor in BBCode mode. The build runs it after packing; to regenerate only the descriptions, run it on its own, in VS Code with the **Nexus descriptions** task.

```powershell
./build/nexus-descriptions.ps1
```
