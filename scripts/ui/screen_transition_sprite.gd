extends TextureRect

signal transition_animation_finished()

enum RectSide {
	TOP,
	RIGHT,
	BOTTOM,
	LEFT,
}

const _PROGRESS_PARAMETER = "progress"
const _SIDE_PARAMETER = "moving_side"

## Delay in seconds after screen wipe ends before emitting
## transition_animation_finished signal
const _TRANSITION_TIME = 0.333

## How long screen wipe takes to complete in both directions,
## in seconds
const _SCREEN_WIPE_DURATION = 0.333

var _shader_timer := Timer.new()
var _animation_active := false
var _active_side := RectSide.TOP
var _active_duration := _SCREEN_WIPE_DURATION

## Determines the direction the moving side of the screen wipe
## travels in[br]
## - `_animation_direction > 0`: downward movement[br]
## - `_animation_direction < 0`: upward movement
var _animation_direction := 0
var _animation_progress := 0.0

## Determines which side of the sprite to affect when animating entering
@export var enter_side := RectSide.TOP

## Determines which side of the sprite to affect when animating exiting
@export var exit_side := RectSide.BOTTOM
@export var enter_duration := _SCREEN_WIPE_DURATION
@export var exit_duration := _SCREEN_WIPE_DURATION

func _ready() -> void:

	_shader_timer.autostart = false
	_shader_timer.one_shot = true
	
	_shader_timer.timeout.connect(func(): 
		_animation_active = false
		transition_animation_finished.emit()
		_animation_progress = 0.0
	)

	add_child(_shader_timer)


func _process(delta: float) -> void:
	if _animation_active:
		var _fill_rate = (1.0 / _active_duration)
		_animation_progress += _fill_rate * delta * _animation_direction
		_set_sprite_fill(smoothstep(0.0, 1.0, _animation_progress), _active_side)
		#_set_sprite_fill(_animation_progress, _active_side)


## Animate the **sprite** entering (becomes visible)
func play_enter_animation() -> void:

	if _animation_active:
		return

	show()
	_active_duration = enter_duration
	_animation_active = true
	_active_side = enter_side
	material.set_shader_parameter(_SIDE_PARAMETER, _active_side)
	_shader_timer.start(_TRANSITION_TIME + _active_duration)

	# Start empty
	_animation_progress = 0.0
	_set_sprite_fill(_animation_progress, enter_side)

	# Progress forward
	_animation_direction = 1


## Animate the **sprite** exiting (becomes invisible)
func play_exit_animation() -> void:

	if _animation_active:
		return

	show()
	_active_duration = exit_duration
	_animation_active = true
	_active_side = exit_side
	material.set_shader_parameter(_SIDE_PARAMETER, _active_side)
	_shader_timer.timeout.connect(func():
		hide(), ConnectFlags.CONNECT_ONE_SHOT)
	_shader_timer.start(_TRANSITION_TIME)

	# Start full
	_animation_progress = 1.0
	_set_sprite_fill(_animation_progress, exit_side)

	# Progress backward
	_animation_direction = -1


func _set_sprite_fill(fill_percent: float, side: RectSide) -> void:

	var fill_length := size.y if side == RectSide.TOP or side == RectSide.BOTTOM else size.x

	var fill_position := position.y if side == RectSide.TOP or side == RectSide.BOTTOM else position.x

	var shader_progress := 0.0

	if side == RectSide.TOP or side == RectSide.LEFT:
		shader_progress = fill_position + (fill_length - fill_percent * fill_length)
	else:
		shader_progress = fill_position + fill_percent * fill_length

	material.set_shader_parameter(_PROGRESS_PARAMETER, shader_progress)
