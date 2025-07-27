extends Node2D

@export var _origin: Node2D
@export var _line: Line2D
@export var _max_points: int = 10

var velocity: Vector2
var acceleration: Vector2
var active: bool = false
var step = 0.05

const _HALF = 0.50

func _ready() -> void:
	deactivate_trajectory()


func path(t: float) -> Vector2:
	var x = velocity.x * t + _HALF * acceleration.x * pow(t, 2.0)
	var y = velocity.y * t + _HALF * acceleration.y * pow(t, 2.0)
	return Vector2(x, y)


func _get_points() -> Array[Vector2]:
	var points: Array[Vector2] = []
	var t = 0.0
	var count = 0;
	while count < _max_points:
		count += 1
		points.append(path(t).rotated(-_origin.rotation))
		t += step
	return points


func show_trajectory(velocity: Vector2, acceleration: Vector2) -> void:
	if not active: return
	self.velocity = velocity
	self.acceleration = acceleration
	var points = _get_points()
	_line.points = points


func activate_trajectory() -> void:
	_line.show()
	active = true


func deactivate_trajectory() -> void:
	_line.hide()
	active = false
