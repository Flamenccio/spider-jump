extends Camera2D

@export var _follow_target: Node2D

## If true, the camera moves up and down with the player.
## [br]
## Otherwise, only moves up
@export var _debug: bool = false

func _ready() -> void:
	GameConstants.main_camera = self


func _process(delta: float) -> void:
	# Debug movement
	if _debug:
		_debug_movement()
	else:
		_movement()


func _debug_movement() -> void:
	if _follow_target != null:
		global_position = Vector2(global_position.x, _follow_target.global_position.y)


func _movement() -> void:
	if _follow_target != null:
		var new_vertical = minf(global_position.y, _follow_target.global_position.y)
		var new_position = Vector2(global_position.x, new_vertical)
		global_position = new_position


func screen_to_world_point(screen_point: Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * screen_point


func world_to_screen_point(world_point: Vector2) -> Vector2:
	return get_canvas_transform() * world_point

