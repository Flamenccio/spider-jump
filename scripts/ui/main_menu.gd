extends Control

const ARCADE_GAME_UID = "uid://c3vqs430qpt8w"

func _load_arcade() -> void:
	var path = ResourceUID.uid_to_path(ARCADE_GAME_UID)
	if get_tree().change_scene_to_file(path) != OK:
		push_error("main menu: something went wrong!")


func _quit_game() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()