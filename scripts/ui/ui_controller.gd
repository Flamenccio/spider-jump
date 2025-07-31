extends Control

signal internal_score_updated(score: int)
signal internal_high_score_updated(score: int)

@export var _visible_on_ready: bool = true

func _ready() -> void:
	if _visible_on_ready:
		show()
	else:
		hide()


func _update_score(score: int) -> void:
	internal_score_updated.emit(score)


func _update_high_score(score: int) -> void:
	internal_high_score_updated.emit(score)

