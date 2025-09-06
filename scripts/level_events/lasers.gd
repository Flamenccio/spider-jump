extends LevelEvent

@export var _laser_attack_scene: PackedScene
var _laser_timer: Timer = Timer.new()
var _laser_attack: Node2D
var _defer_event_end: bool = false
# Time in seconds between laser attack waves
const _LASER_BASE_FREQUENCY = 4.0

func _ready() -> void:
	_laser_timer.wait_time = _LASER_BASE_FREQUENCY
	_laser_timer.one_shot = true
	_laser_timer.timeout.connect(_start_laser_attack)
	add_child(_laser_timer)


func start_event() -> void:
	_activated = true
	_laser_attack = _laser_attack_scene.instantiate() as Node2D
	get_parent().add_child(_laser_attack)
	_laser_attack.attack_ended.connect(_on_laser_attack_ended)
	_start_laser_attack()


func end_event() -> void:

	# If there is a laser attack happening, end the event after the attack ends.
	if _laser_timer.wait_time > 0.0:
		if not _defer_event_end:
			_defer_event_end = true
		return

	_laser_timer.stop()
	_laser_attack.queue_free()
	self.queue_free()


func _on_laser_attack_ended() -> void:
	if _defer_event_end:
		_laser_timer.stop()
		_laser_attack.queue_free()
		self.queue_free()
		return
	_laser_timer.start()


func _start_laser_attack() -> void:
	_laser_attack.start_attack()

