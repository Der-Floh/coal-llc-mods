extends "res://scripts/Gvars.gd"

# Tick-speed multipliers for poison and fire effects.
# 1.0 = vanilla rate; 2.0 = twice as many ticks per second (doubles DPS).
# Modified at runtime by the in-game passive chooser when the player picks
# the corresponding upgrade.
var poison_tick_speed: float = 1.0
var fire_tick_speed: float = 1.0
