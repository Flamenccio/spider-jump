extends RigidBody2D

signal internal_move_input_change(move_input: Vector2)
signal internal_pull_input_change(pull_input: Vector2)
signal internal_pull_release()
var _gravity_scale: float

func _ready() -> void:
	_gravity_scale = gravity_scale


func on_stick() -> void:
	gravity_scale = 0.0
	linear_velocity = Vector2.ZERO


func on_unstick() -> void:
	gravity_scale = _gravity_scale


func _on_input_service_move_input_change(move_input: Vector2) -> void:
	internal_move_input_change.emit(move_input)


func _on_input_service_pull_input_change(pull_input: Vector2) -> void:
	internal_pull_input_change.emit(pull_input)


func _on_input_service_pull_release() -> void:
	internal_pull_release.emit()
