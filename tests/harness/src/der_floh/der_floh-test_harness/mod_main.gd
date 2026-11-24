extends Node

const LOG_NAME := "der_floh-test_harness:Main"
const PORT_ARG := "--harness-port="
const TOKEN_ARG := "--harness-token="
const SCREENSHOTS_ARG := "--harness-screenshots="
const DEFAULT_SCREENSHOT_FOLDER := "harness_screenshots"
const WINDOW_SIZE := Vector2i(1280, 720)
const ProfileSwitch := preload("res://mods-unpacked/der_floh-test_harness/profile_switch.gd")
const Server := preload("res://mods-unpacked/der_floh-test_harness/server.gd")
const Commands := preload("res://mods-unpacked/der_floh-test_harness/commands.gd")
const GameAccess := preload("res://mods-unpacked/der_floh-test_harness/game_access.gd")

var _port := 0
var _token := ""
var _screenshot_dir := ""
var _restarting := false
var _server: Server
var _commands: Commands


func _init() -> void:
	ProfileSwitch.remove()
	_read_user_args()


func _ready() -> void:
	if _port <= 0 or _token.is_empty():
		ModLoaderLog.warning("No --harness-port/--harness-token user args, so the harness stays off.", LOG_NAME)
		return
	if not ProfileSwitch.is_active():
		_close_outside_test_profile()
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	_restart_when_hooks_are_rebuilt()
	# The parent ModLoader's _ready runs after this one and may rebuild the hook pack, which restarts the game.
	await get_tree().process_frame
	if _restarting:
		return
	_disable_achievements()
	_use_test_window()
	_start_server()


func _process(_delta: float) -> void:
	if _server:
		_server.poll()


func _exit_tree() -> void:
	if _server:
		_server.stop()


func _read_user_args() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with(PORT_ARG):
			_port = int(arg.trim_prefix(PORT_ARG))
		elif arg.begins_with(TOKEN_ARG):
			_token = arg.trim_prefix(TOKEN_ARG)
		elif arg.begins_with(SCREENSHOTS_ARG):
			_screenshot_dir = arg.trim_prefix(SCREENSHOTS_ARG)
	if _screenshot_dir.is_empty():
		_screenshot_dir = OS.get_user_data_dir().path_join(DEFAULT_SCREENSHOT_FOLDER)


func _start_server() -> void:
	_commands = Commands.new(GameAccess.new(get_tree()), _screenshot_dir)
	_server = Server.new()
	var error := _server.start(_port, _token, _commands.handle)
	if error != OK:
		ModLoaderLog.error("Could not listen on 127.0.0.1:%d (%s)." % [_port, error_string(error)], LOG_NAME)
		_server = null
		return
	ModLoaderLog.info("Listening on 127.0.0.1:%d." % _port, LOG_NAME)


func _restart_when_hooks_are_rebuilt() -> void:
	var mod_loader := get_node_or_null("/root/ModLoader")
	if mod_loader and mod_loader.has_signal("new_hooks_created"):
		mod_loader.connect("new_hooks_created", _restart_into_test_profile)


func _restart_into_test_profile() -> void:
	_restarting = true
	ModLoaderLog.info("New mod hooks were generated, restarting into the test profile.", LOG_NAME)
	ProfileSwitch.write()
	var args := OS.get_cmdline_args()
	args.append("--")
	args.append_array(OS.get_cmdline_user_args())
	OS.set_restart_on_exit(true, args)
	get_tree().quit()


# Killed rather than quit, because quitting saves the game into the profile it wrongly started in.
func _close_outside_test_profile() -> void:
	ModLoaderLog.error("Started in %s instead of the %s profile; closing without saving." % [OS.get_user_data_dir(), ProfileSwitch.PROFILE_NAME], LOG_NAME)
	OS.kill(OS.get_process_id())


func _disable_achievements() -> void:
	var steamworks := get_node_or_null("/root/SteamWorks")
	if steamworks and "steam_powered" in steamworks:
		steamworks.steam_powered = false


func _use_test_window() -> void:
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(WINDOW_SIZE)
