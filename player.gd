extends RigidBody2D

var _gravity_scale: float

func _ready() -> void:
	_gravity_scale = gravity_scale


func on_stick() -> void:
	gravity_scale = 0.0
	linear_velocity = Vector2.ZERO


func on_unstick() -> void:
	gravity_scale = _gravity_scale