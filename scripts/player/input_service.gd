extends Node

signal move_input_change(move_input: Vector2)
signal pull_input_change(pull_input: Vector2)
signal pull_release()
signal pull_press()

@export var _pull_origin: Node2D
var _current_move_input: Vector2 = Vector2.ZERO
var _joypad_input: bool = false
var _current_max_pull_distance: float

# When using KBM pull, the maximum distance from the
# pull origin (player) that results in the highest
# launch power when released from this distance.
const _MAX_PULL_DISTANCE = 32.0
const _MIN_PULL_DISTANCE = 8.0

## When using KBM, the maximum distance from the
## pull origin when using the hoverfly powerup.
const _MAX_PULL_DISTANCE_HOVER = 48.0

func _ready() -> void:

	if _pull_origin == null:
		printerr('input service: pull origin is null')
		return

	Input.joy_connection_changed.connect(_handle_joy_connection_change)
	PlayerEventBus.powerup_started.connect(_handle_powerup)
	PlayerEventBus.powerup_ended.connect(_handle_powerup_end)
	_current_max_pull_distance = _MAX_PULL_DISTANCE


func _handle_powerup(powerup: String) -> void:
	if powerup == 'hoverfly':
		_current_max_pull_distance = _MAX_PULL_DISTANCE_HOVER


func _handle_powerup_end(powerup: String) -> void:
	if powerup == 'hoverfly':
		_current_max_pull_distance = _MAX_PULL_DISTANCE


func _handle_joy_connection_change(device: int, connect: bool) -> void:

	if connect: print('connected: ', device)
	else: print('disconnected: ', device)

	_joypad_input = Input.get_connected_joypads().size() > 0


func _input(event: InputEvent) -> void:
	_handle_move_input()
	_handle_pull(event)


func _process(delta: float) -> void:
	if _joypad_input:
		_handle_pull_input_joy()
	else:
		_handle_pull_input_kbm()
	# debug draw
	#DebugDraw2D.circle(_pull_origin.global_position, _MAX_PULL_DISTANCE, 16, Color.RED, 0.5, delta)


func _handle_move_input() -> void:

	var temp_input := Input.get_vector('move_left', 'move_right', 'move_up', 'move_down')
	
	if _current_move_input != temp_input:
		move_input_change.emit(temp_input)
		_current_move_input = temp_input


func _handle_pull_input_joy() -> void:
	var pull = Input.get_vector('pull_left', 'pull_right', 'pull_up', 'pull_down')
	pull_input_change.emit(pull)


func _handle_pull(event: InputEvent) -> void:
	if event.is_action_released('pull_button'):
		pull_release.emit()
	if event.is_action_pressed("pull_button"):
		pull_press.emit()


func _handle_pull_input_kbm() -> void:

	if not Input.is_action_pressed('pull_button'):
		return

	var global_mouse_position := _pull_origin.get_global_mouse_position()
	var raw_pull := global_mouse_position - _pull_origin.global_position
	var normalized_pull := raw_pull.normalized()
	var magnitude := clampf(raw_pull.length(), 0.0, _current_max_pull_distance)
	magnitude = magnitude / _current_max_pull_distance
	
	var final := normalized_pull * magnitude
	pull_input_change.emit(final)


# Returns a vector whose magnitude is 0.0 - 1.0
func _vector2_deadzone(raw_input: Vector2, deadzone_magnitude: float, maximum_magnitude: float) -> Vector2:
	var processed_x := _deadzone(raw_input.x, deadzone_magnitude, maximum_magnitude)
	var processed_y := _deadzone(raw_input.y, deadzone_magnitude, maximum_magnitude)
	return Vector2(processed_x, processed_y)


func _deadzone(raw_input: float, deadzone: float, maximum: float) -> float:
	var raw_input_sign = sign(raw_input)
	var processed_input = maxf(abs(raw_input), deadzone)
	return raw_input_sign * (processed_input - deadzone) / (maximum - deadzone)


