extends RefCounted

# Godot reads override.cfg next to the exe at startup; this one points user:// at a separate test profile.
const FILE_NAME := "override.cfg"
const PROFILE_NAME := "Coal LLC Test"
const MARKER := "; der_floh-test_harness: temporary switch to the " + PROFILE_NAME + " profile"
const CONTENT := MARKER + "\n[application]\n\nconfig/use_custom_user_dir=true\nconfig/custom_user_dir_name=\"" + PROFILE_NAME + "\"\n"


static func file_path() -> String:
	return OS.get_executable_path().get_base_dir().path_join(FILE_NAME)


static func is_active() -> bool:
	return OS.get_user_data_dir().get_file() == PROFILE_NAME


static func write() -> void:
	var file := FileAccess.open(file_path(), FileAccess.WRITE)
	if file:
		file.store_string(CONTENT)


static func remove() -> void:
	var path := file_path()
	if FileAccess.file_exists(path) and FileAccess.get_file_as_string(path).begins_with(MARKER):
		DirAccess.remove_absolute(path)
