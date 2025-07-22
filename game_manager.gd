extends Node2D

signal on_game_over()
signal stamina_drained(amount: float)

## Base amount of stamina drained per second, from 0.0 - 1.0
@export var _base_stamina_drain_amount: float = 0.0
var _stamina_drain_amount: float = 0.0

func _ready() -> void:
	_stamina_drain_amount = _base_stamina_drain_amount


func game_over() -> void:
	get_tree().paused = true
	on_game_over.emit()


func _process(delta: float) -> void:
	stamina_drained.emit(_stamina_drain_amount * delta * -1)
