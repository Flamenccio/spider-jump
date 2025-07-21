extends RigidBody2D

signal internal_move_input_change(move_input: Vector2)
signal internal_pull_input_change(pull_input: Vector2)
signal internal_pull_release()
signal internal_pull_press()
signal stop_moving()
signal moving()

var _gravity_scale: float

func _ready() -> void:
	_gravity_scale = gravity_scale


func on_stick() -> void:
	linear_velocity = Vector2.ZERO
	gravity_scale = 0.0


func on_unstick() -> void:
	gravity_scale = _gravity_scale


func _on_input_service_move_input_change(move_input: Vector2) -> void:
	internal_move_input_change.emit(move_input)

	if move_input.x == 0:
		stop_moving.emit()
	else:
		moving.emit()


func _on_input_service_pull_input_change(pull_input: Vector2) -> void:
	internal_pull_input_change.emit(pull_input)


func _on_input_service_pull_release() -> void:
	internal_pull_release.emit()


func _on_input_service_pull_press() -> void:
	internal_pull_press.emit()


func _rotate_against_normal(normal: Vector2) -> void:
	# The player UP vector must match the given normal
	var up_angle := rotation - PI / 2.0
	var up_vector := Vector2.from_angle(up_angle)
	var difference := up_vector.angle_to(normal)
	rotation += difference
