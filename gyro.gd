extends Node2D

## The global angle to maintain as the pivot point moves and rotates
@export_range(0.0, 360.0) var _gyro_angle_degrees: float
@export var _pivot_point: Node2D
@onready var _gyro_angle_rad: float = deg_to_rad(_gyro_angle_degrees)

func _physics_process(delta: float) -> void:
	var pivot_rotation := _pivot_point.rotation
	var angle_to_pivot := _gyro_angle_rad - pivot_rotation
	rotation = angle_to_pivot

