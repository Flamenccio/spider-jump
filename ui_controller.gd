extends Control

@export var _visible_on_ready: bool = true

func _ready() -> void:
	if _visible_on_ready:
		show()
	else:
		hide()
