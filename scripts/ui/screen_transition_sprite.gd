extends TextureRect

signal transition_animation_finished()

const _START_TIME_PARAMETER = "start_time"
const _DIRECTION_PARAMETER = "direction"
const _TRANSITION_TIME = 2.0

var _shader_timer := Timer.new()
var _animation_active := false

func _ready() -> void:

	_shader_timer.autostart = false
	_shader_timer.one_shot = true
	
	# Remove shader when the shader timer times out
	_shader_timer.timeout.connect(func(): 
		_animation_active = false
		transition_animation_finished.emit()
	)

	add_child(_shader_timer)


func play_enter_animation() -> void:
	if _animation_active:
		return
	_play_animation(1)


func play_exit_animation() -> void:
	if _animation_active:
		return
	_shader_timer.timeout.connect(func():
		hide(), ConnectFlags.CONNECT_ONE_SHOT)
	_play_animation(-1)


func _play_animation(direction: int) -> void:
	_animation_active = true
	var current_time := Time.get_ticks_msec() / 1000.0
	material.set_shader_parameter(_DIRECTION_PARAMETER, direction)
	material.set_shader_parameter(_START_TIME_PARAMETER, current_time)
	_shader_timer.start(_TRANSITION_TIME)
	show()
	print("SHOW")

