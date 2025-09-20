extends TextureRect

signal transition_animation_finished()

const _PROGRESS_PARAMETER = "progress"
const _SIDE_PARAMETER = "move_top_side"

## Delay in seconds after screen wipe starts before emitting
## transition_animation_finished signal
const _TRANSITION_TIME = 0.666

## How long screen wipe takes to complete in both directions,
## in seconds
const _SCREEN_WIPE_DURATION = 0.333

var _shader_timer := Timer.new()
var _animation_active := false

## Determines the direction the moving side of the screen wipe
## travels in[br]
## - `_animation_direction > 0`: downward movement[br]
## - `_animation_direction < 0`: upward movement
var _animation_direction := 0
var _animation_progress := 0.0

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
		var _fill_rate = (1.0 / _SCREEN_WIPE_DURATION)
		_animation_progress += _fill_rate * delta * _animation_direction
		_set_sprite_fill(_animation_progress)


func play_enter_animation() -> void:
	if _animation_active:
		return
	show()
	_animation_active = true
	_animation_direction = 1
	material.set_shader_parameter(_SIDE_PARAMETER, false)
	_shader_timer.start(_TRANSITION_TIME)


func play_exit_animation() -> void:
	if _animation_active:
		return
	material.set_shader_parameter(_SIDE_PARAMETER, true)
	_animation_progress = 0.0
	_set_sprite_fill(_animation_progress)
	show()
	_animation_active = true
	_animation_direction = 1
	_shader_timer.timeout.connect(func():
		hide()
	, ConnectFlags.CONNECT_ONE_SHOT)
	_shader_timer.start(_TRANSITION_TIME)


func _set_sprite_fill(fill_percent: float) -> void:
	material.set_shader_parameter(_PROGRESS_PARAMETER, position.y + fill_percent * size.y)
