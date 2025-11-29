extends Camera2D

const _MAX_SCREEN_SHAKE_POWER = 1.0
const _MIN_SCREEN_SHAKE_POWER = 0.0
const _SCREEN_SHAKE_DURATION_SECONDS = 0.20
const _SCREEN_SHAKE_MAX_INTENSITY = 5.0

const _MIN_SMOOTHING_SPEED = 3.0
const _MAX_SMOOTHING_SPEED = 4.5
const _MIN_PLAYER_SPEED = 0.0
const _MAX_PLAYER_SPEED = 300.0

const _SMOOTHING_RATIO = (_MAX_SMOOTHING_SPEED - _MIN_SMOOTHING_SPEED) / (_MAX_PLAYER_SPEED - _MIN_PLAYER_SPEED)

var _screen_shake_timer := Timer.new()
var _screen_shake_intensity := 0.0

@export var _follow_target: Node2D

## If true, the camera moves up and down with the player.
## [br]
## Otherwise, only moves up
@export var _debug: bool = false

func _ready() -> void:
	GameConstants.main_camera = self

	_screen_shake_timer.timeout.connect(end_screen_shake)
	_screen_shake_timer.one_shot = true
	add_child(_screen_shake_timer)


func _process(delta: float) -> void:

	# Debug movement
	if _debug:
		_debug_movement()
	else:
		_movement()
		_set_dynamic_smoothing_speed()


func _physics_process(delta: float) -> void:
	if _screen_shake_intensity > 0:
		var point = _get_point_in_circle()
		offset = point * _screen_shake_intensity


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


## Make the camera shake a bit, with [code]power[/code] affecting the intensity
## of the screen shake. This value has a range from 0 to 1.
func screen_shake(power: float) -> void:
	_screen_shake_timer.stop()
	power = clampf(power, _MIN_SCREEN_SHAKE_POWER, _MAX_SCREEN_SHAKE_POWER)
	_screen_shake_intensity = power * _SCREEN_SHAKE_MAX_INTENSITY
	_screen_shake_timer.start(_SCREEN_SHAKE_DURATION_SECONDS)


func _get_point_in_circle() -> Vector2:
	var random_angle = randf() * 2.0 * PI
	return Vector2(cos(random_angle), sin(random_angle))


func _set_dynamic_smoothing_speed() -> void:
	if GameConstants.player == null:
		return
	if not position_smoothing_enabled:
		return
	var player_speed = GameConstants.player.get_real_velocity().length()
	player_speed = clampf(player_speed, _MIN_PLAYER_SPEED, _MAX_PLAYER_SPEED)
	var target_smoothing = _SMOOTHING_RATIO * player_speed + (_MIN_SMOOTHING_SPEED - _SMOOTHING_RATIO * _MIN_PLAYER_SPEED)
	position_smoothing_speed = lerpf(position_smoothing_speed, target_smoothing, 0.05)


func end_screen_shake() -> void:
	_screen_shake_intensity = 0.0
	_screen_shake_timer.stop()
