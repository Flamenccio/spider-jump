extends Node

const _ARCADE_SCENE_UID = "uid://c3vqs430qpt8w"

@export var _screen_transition: ScreenTransition

func _on_tutorial_finished() -> void:
	_screen_transition.enter_transition_finished.connect(
		func(): 
			get_tree().change_scene_to_file(ResourceUID.uid_to_path(_ARCADE_SCENE_UID)),
		ConnectFlags.CONNECT_ONE_SHOT
	)
	_screen_transition.play_enter_animation()
