class_name DerFlohPickaxeAoeMod
extends Node

const MOD_ID := "der_floh-pickaxeaoe_mod"
const MOD_DIR := "der_floh-pickaxeaoe_mod"
const LOG_NAME := "der_floh-pickaxeaoe_mod:Main"

var mod_dir_path := ""
var extensions_dir_path := ""


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	extensions_dir_path = mod_dir_path.path_join("extensions")
	install_hooks()


func install_hooks() -> void:
	ModLoaderMod.install_script_hooks(
		"res://scripts/StateMachine/Player2/player_2.gd",
		extensions_dir_path.path_join("scripts/StateMachine/Player2/player_2.hooks.gd")
	)
	ModLoaderLog.info("Installed mine_action hook — AOE and electric pickaxe now deal equal damage to all ores.", LOG_NAME)
