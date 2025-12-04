extends Control

@export var _tutorial_animation_player: AnimationPlayer
@export var _tutorial_animation_name: String

func play_tutorial() -> void:
	if _tutorial_animation_name.is_empty():
		push_warning("Unable to play tutorial animation: given animation name is empty")
		return
	if _tutorial_animation_player == null:
		push_warning("Unable to play tutorial animation: animation player is null")
		return
	if not _tutorial_animation_player.has_animation(_tutorial_animation_name):
		push_warning("Unable to play tutorial animation: no such animation with name '{0}'".format({"0": _tutorial_animation_name}))
		return
	_tutorial_animation_player.play(_tutorial_animation_name)


func stop_tutorial() -> void:
	if _tutorial_animation_player == null:
		push_warning("Unable to stop animation: animation player is null")
		return
	_tutorial_animation_player.stop()
