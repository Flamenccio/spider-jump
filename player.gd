extends RigidBody2D

var _gravity_scale: float

func _ready() -> void:
	_gravity_scale = gravity_scale


func on_stick() -> void:
	gravity_scale = 0.0
	linear_velocity = Vector2.ZERO


func on_unstick() -> void:
	gravity_scale = _gravity_scale


func _on_wall_detector_collision_normal(normal:Vector2) -> void:
	#var normal_angle := normal.angle() + PI / 2.0
	#rotation = normal_angle
	pass
