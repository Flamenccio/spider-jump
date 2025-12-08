extends Camera2D

# Screen shaking
const _MAX_SCREEN_SHAKE_POWER = 1.0
const _MIN_SCREEN_SHAKE_POWER = 0.0
const _SCREEN_SHAKE_DURATION_SECONDS = 0.20
const _SCREEN_SHAKE_MAX_INTENSITY = 5.0

# Dynamic camera speed
const _MIN_SMOOTHING_SPEED = 3.0
const _MAX_SMOOTHING_SPEED = 5.0
const _MIN_PLAYER_SPEED = 0.0
const _MAX_PLAYER_SPEED = 300.0
const _SMOOTHING_RATIO = (_MAX_SMOOTHING_SPEED - _MIN_SMOOTHING_SPEED) / (_MAX_PLAYER_SPEED - _MIN_PLAYER_SPEED)

# Camera peeking
const _PEEK_TRIGGER_MOUSE_DISTANCE = 0.8

var _screen_shake_timer := Timer.new()
var _screen_shake_intensity := 0.0
var _player_pulling := false
var _peek_offset := Vector2.ZERO
var follow_offset := Vector2.ZERO
var _screen_shake_offset := Vector2.ZERO

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

	PlayerEventBus.powerup_started.connect(_on_powerup_started)
	PlayerEventBus.powerup_ended.connect(_on_powerup_ended)


func _process(delta: float) -> void:

	# Debug movement
	if _debug:
		_debug_movement()
	else:
		_movement()
		_set_dynamic_smoothing_speed()

	if _player_pulling:
		_peek_mouse()
	else:
		_peek_offset = _peek_offset.lerp(Vector2.ZERO, 0.05)


func _physics_process(delta: float) -> void:
	if _screen_shake_intensity > 0:
		var point = _get_point_in_circle()
		_screen_shake_offset = point * _screen_shake_intensity
	offset = _screen_shake_offset + _peek_offset + follow_offset


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
	_screen_shake_offset = Vector2.ZERO
	_screen_shake_timer.stop()


func _on_pull_pressed() -> void:
	_player_pulling = true


func _on_pull_released() -> void:
	_player_pulling = false


# Move the camera offset down if the mouse is
# close to the bottom edge
func _peek_mouse() -> void:

	var viewport_mouse_position = get_viewport().get_mouse_position()
	var normalized_mouse_position = viewport_mouse_position / get_viewport_rect().size

	var camera_player_height_difference = global_position.y + follow_offset.y - _follow_target.global_position.y
	var mouse_close = normalized_mouse_position.y >= _PEEK_TRIGGER_MOUSE_DISTANCE
	var player_close = camera_player_height_difference <= -48.0

	if mouse_close and player_close:
		_peek_offset = Vector2(0.0, lerpf(_peek_offset.y, 24.0 + absf(follow_offset.y), 0.02)) 
	elif not mouse_close and player_close:
		_peek_offset = _peek_offset.lerp(Vector2.ZERO, 0.05)


func smooth_zoom(zoom_level: float) -> void:
	var z = Vector2(zoom_level, zoom_level)
	var tween = create_tween()
	tween.tween_property(self, "zoom", z, 0.5)
	tween.set_trans(Tween.TRANS_SINE)


func _on_powerup_started(powerup: String) -> void:
	match powerup:
		ItemIds.HOVERFLY_POWERUP:
			set_follow_offset(-32.0)
		ItemIds.HOPPERPOP_POWERUP:
			set_follow_offset(-32.0)
		ItemIds.ANTIBUG_POWERUP:
			set_follow_offset(-32.0)
		_:
			return


func _on_powerup_ended(_powerup: String) -> void:
	set_follow_offset(0.0, 3.3)


func set_follow_offset(offset: float, duration := 0.3) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "follow_offset", Vector2(0, offset), duration) 

