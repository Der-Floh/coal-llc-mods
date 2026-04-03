class_name DerFlohPerfMod
extends Node

const MOD_ID := "der_floh-performance_mod"
const MOD_DIR := "der_floh-performance_mod"
const LOG_NAME := "der_floh-performance_mod:Main"

var mod_dir_path: String
var extensions_dir_path: String


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	extensions_dir_path = mod_dir_path.path_join("extensions")
	install_hooks()


func install_hooks() -> void:
	ModLoaderMod.install_script_hooks(
		"res://scenes/tilemaps/tile_map_manager.gd",
		extensions_dir_path.path_join("scenes/tilemaps/tile_map_manager.hooks.gd")
	)
	ModLoaderMod.install_script_hooks(
		"res://scenes/tilemaps/tile_map_chunk.gd",
		extensions_dir_path.path_join("scenes/tilemaps/tile_map_chunk.hooks.gd")
	)
