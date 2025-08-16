extends Node

var _life_timer: Timer = Timer.new()

func _ready() -> void:
	_life_timer.one_shot = true
	_life_timer.timeout.connect(func(): queue_free())
	add_child(_life_timer)
	_life_timer.start(0.33333)
