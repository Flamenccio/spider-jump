extends Node

signal powerup_started(powerup: String)
signal powerup_ended()

signal hoverfly_started()
signal hoverfly_ended()

signal antibug_started()
signal antibug_ended()

var current_powerup: String = ''
var _powerup_end_queue: Array[Callable]
var _powerup_timer: Timer = Timer.new()

func _ready() -> void:
	_powerup_timer.timeout.connect(_end_powerups)
	_powerup_timer.one_shot = true
	add_child(_powerup_timer)


func _on_powerup_consumed(powerup: String) -> void:
	_handle_powerup(powerup)


func _end_powerups() -> void:
	_powerup_timer.stop()
	if _powerup_end_queue.size() > 0:
		powerup_ended.emit()
		PlayerEventBus.powerup_ended.emit()
	while _powerup_end_queue.size() > 0:
		var p = _powerup_end_queue.pop_front() as Callable
		p.call()


func _handle_powerup(powerup: String) -> void:

	# End any existing powerup
	_end_powerups()
	powerup_started.emit(powerup)
	PlayerEventBus.powerup_started.emit(powerup)
	current_powerup = powerup

	match powerup:
		'hoverfly':
			hoverfly_started.emit()
			_powerup_end_queue.push_back(func(): hoverfly_ended.emit())
			_powerup_timer.start(10)
		'antibug':
			antibug_started.emit()
			_powerup_end_queue.push_back(func():
				antibug_ended.emit()
				GameConstants.current_gravity = GameConstants.DEFAULT_GRAVITY
			)
			_powerup_timer.start(10)
			GameConstants.current_gravity = -GameConstants.DEFAULT_GRAVITY
		_:
			printerr('powerup handler: unhandled powerup "{0}"'.format({'0': powerup}))
			return


func _process(delta: float) -> void:
	if current_powerup != '':
		PlayerEventBus.powerup_timer_updated.emit(_powerup_timer.time_left, _powerup_timer.wait_time)

