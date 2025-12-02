extends Control

const ARCADE_GAME_UID = "uid://c3vqs430qpt8w"
const TUTORIAL_SCREEN_UID = "uid://bh66jtkoetxiq"
const PLAYER_SETTINGS_PATH = "res://resources/settings/player_settings.res"

var _queued_game_mode := ""

func _queue_load_arcade() -> void:
	if _queued_game_mode != "":
		return

	var settings = SettingsService.get_settings()
	if settings.get("repeat_tutorial") or not settings.get("tutorial_played"):
		_queued_game_mode = "tutorial"
		return

	_queued_game_mode = "arcade"


func _load_arcade() -> void:
	_switch_scene(ARCADE_GAME_UID)


func _load_tutorial() -> void:
	SettingsService.update_setting("tutorial_played", true)
	SettingsService.write_settings()
	_switch_scene(TUTORIAL_SCREEN_UID)


func _switch_scene(uid: String) -> void:
	var path = ResourceUID.uid_to_path(uid)
	if get_tree().change_scene_to_file(path) != OK:
		push_error("main menu: something went wrong!")


func _quit_game() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _on_black_transition_animation_finished() -> void:
	match _queued_game_mode:
		"arcade":
			_load_arcade()
		"tutorial":
			_load_tutorial()
		_:
			return
