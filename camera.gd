extends Camera2D

@export var _follow_target: Node2D

func _process(delta: float) -> void:
	if _follow_target != null:
		global_position = _follow_target.global_position