extends Node2D

@export var _upward_speed: float = 1.0
var _move_vector: Vector2
var _death_timer: Timer = Timer.new()

const _LIFETIME = 1.5

func _ready() -> void:
	_move_vector = Vector2(0.0, -_upward_speed)
	_death_timer.one_shot = true
	_death_timer.timeout.connect(func(): queue_free())
	add_child(_death_timer)
	_death_timer.start(_LIFETIME)


func _process(delta: float) -> void:
	global_position += _move_vector * delta
