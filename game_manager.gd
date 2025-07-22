extends Node2D

signal on_game_over()

func game_over() -> void:
	get_tree().paused = true
	on_game_over.emit()
