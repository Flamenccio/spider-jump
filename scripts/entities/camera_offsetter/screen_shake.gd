extends CameraOffsetter

const _DEFAULT_SHAKE_DURATION = 0.20
const _MAX_SHAKE_INTENSITY = 1.0
const _MIN_SHAKE_INTENSITY = 0.0
const _DEFAULT_SHAKE_LENGTH = 5.0

var _screen_shake_timer := Timer.new()
var _screen_shake_active := false
var _screen_shake_intensity := _MIN_SHAKE_INTENSITY:
	set(value):
		_screen_shake_intensity = clampf(value, _MIN_SHAKE_INTENSITY, _MAX_SHAKE_INTENSITY)

func _ready() -> void:
	_screen_shake_timer.one_shot = true
	_screen_shake_timer.wait_time = _DEFAULT_SHAKE_DURATION
	_screen_shake_timer.timeout.connect(_on_screen_shake_timer_timeout)
	add_child(_screen_shake_timer)


func _process(_delta: float) -> void:
	if not _screen_shake_active:
		return
	_sub_offset = _get_point_in_circle() * _screen_shake_intensity * _DEFAULT_SHAKE_LENGTH


func _on_receive_message(msg: String, value: Variant) -> void:
	if msg == "start_screen_shake":
		_screen_shake_intensity = value
		_screen_shake_timer.start()
		_screen_shake_active = true
	elif msg == "end_screen_shake":
		_stop_screen_shake()


func _on_screen_shake_timer_timeout() -> void:
	_stop_screen_shake()


func _stop_screen_shake() -> void:
	_screen_shake_active = false
	_sub_offset = Vector2.ZERO


func _get_point_in_circle() -> Vector2:
	var random_angle = randf() * 2.0 * PI
	return Vector2(cos(random_angle), sin(random_angle))
