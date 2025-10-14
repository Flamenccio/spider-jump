extends Control

signal pause_screen_button_pressed(button: String)
signal pause_screen_animation_done()
signal internal_disabled()
signal internal_enabled()

var _game_paused := false

func _on_pause_screen_enabled() -> void:
	show()
	_game_paused = true
	internal_enabled.emit()


func _on_pause_screen_disabled() -> void:
	_game_paused = false
	internal_disabled.emit()


func _on_title_bar_animation_complete() -> void:
	if _game_paused:
		pause_screen_animation_done.emit()
	else:
		pause_screen_animation_done.emit()
		hide()


func _on_button_pressed(button: String) -> void:
	pause_screen_button_pressed.emit(button)
