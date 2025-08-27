extends Node
## Allows the player to queue inputs for more lenient gameplay

var aim_queue: Vector2
var _current_aim: Vector2 = Vector2.ZERO
var _aim_queue_timer: Timer = Timer.new()

const _INPUT_QUEUE_DURATION = 0.3

func _ready() -> void:
	_aim_queue_timer.wait_time = _INPUT_QUEUE_DURATION
	_aim_queue_timer.timeout.connect(func(): pop_aim_queue())
	_aim_queue_timer.autostart = false
	_aim_queue_timer.one_shot = true
	add_child(_aim_queue_timer)


func _on_aim_input_update(aim: Vector2) -> void:
	_current_aim = aim


func _on_aim_input_release() -> void:
	_aim_queue_timer.stop()
	aim_queue = _current_aim
	_aim_queue_timer.start()


func pop_aim_queue() -> Vector2:
	_aim_queue_timer.stop()
	var a = aim_queue
	aim_queue = Vector2.ZERO
	return a

