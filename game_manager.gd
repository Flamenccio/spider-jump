extends Node2D

signal on_game_over()
signal stamina_drained(amount: float)
signal score_updated(score: int)

## Base amount of stamina drained per second, from 0.0 - 1.0
@export var _base_stamina_drain_amount: float = 0.0
var _stamina_drain_amount: float = 0.0

@export var debug: bool

@export var _player: Node2D

# Player must travel this much vertically to gain one point.
const _PIXEL_PER_POINT = 8

func _ready() -> void:
	_stamina_drain_amount = _base_stamina_drain_amount


func game_over() -> void:
	get_tree().paused = true
	on_game_over.emit()


func _process(delta: float) -> void:
	if not debug:
		stamina_drained.emit(_stamina_drain_amount * delta * -1)
	var point = floori(_player.global_position.y / _PIXEL_PER_POINT)
	score_updated.emit(point)

