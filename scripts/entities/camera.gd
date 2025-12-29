extends Camera2D

signal message_offsetters(msg: String, value: Variant)

## Permanent vertical distance of camera
const _CAMERA_HEIGHT = -20.0

# DYNAMIC CAMERA SPEED
const _MIN_SMOOTHING_SPEED = 4.0
const _MAX_SMOOTHING_SPEED = 8.0
const _MIN_PLAYER_DISTANCE = 0.0
const _MAX_PLAYER_DISTANCE = 16.0
const _SMOOTHING_RATIO = (_MAX_SMOOTHING_SPEED - _MIN_SMOOTHING_SPEED) / (_MAX_PLAYER_DISTANCE - _MIN_PLAYER_DISTANCE)

var _offsetters: Array[CameraOffsetter]

@export var _follow_target: Node2D

## If true, the camera moves up and down with the player.
## [br]
## Otherwise, only moves up
@export var _debug: bool = false

func _ready() -> void:

	GameConstants.main_camera = self

	# Initialize all camera offsetters
	for c in get_children():
		if c is CameraOffsetter:
			c.camera = self
			c.follow_target = _follow_target
			c.world_to_screen_point = world_to_screen_point
			c.screen_to_world_point = screen_to_world_point
			message_offsetters.connect(c._on_receive_message)
			_offsetters.append(c)


func _compile_offsets() -> void:
	var running_total = Vector2.ZERO
	for co in _offsetters:
		running_total += co.get_offset()
	offset = running_total


func _process(_delta: float) -> void:

	# Debug movement
	if _debug:
		_debug_movement()
	else:
		_movement()
		_set_dynamic_smoothing_speed()

	_compile_offsets()


## Make the camera shake a bit, with [code]power[/code] affecting the intensity
## of the screen shake. This value has a range from 0 to 1.
func screen_shake(power: float) -> void:
	message_offsetters.emit("start_screen_shake", power)


func set_powerup_offset(p_offset: float, duration := 0.3) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "_powerup_offset", Vector2(0, p_offset), duration) 


func screen_to_world_point(screen_point: Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * screen_point


func world_to_screen_point(world_point: Vector2) -> Vector2:
	return get_canvas_transform() * world_point


func _debug_movement() -> void:
	if _follow_target != null:
		global_position = Vector2(global_position.x, _follow_target.global_position.y)


func _movement() -> void:
	if _follow_target != null:
		var new_vertical = minf(global_position.y, _follow_target.global_position.y + _CAMERA_HEIGHT)
		var new_position = Vector2(global_position.x, new_vertical)
		global_position = new_position


func _set_dynamic_smoothing_speed() -> void:

	if GameConstants.player == null:
		return
	if not position_smoothing_enabled:
		return

	var player_distance := clampf(
		get_screen_center_position().y - GameConstants.player.global_position.y,
		_MIN_PLAYER_DISTANCE,
		_MAX_PLAYER_DISTANCE
	)

	var target_smoothing = _SMOOTHING_RATIO * player_distance + (_MIN_SMOOTHING_SPEED - _SMOOTHING_RATIO * _MIN_PLAYER_DISTANCE)
	position_smoothing_speed = lerpf(position_smoothing_speed, target_smoothing, 0.05)
