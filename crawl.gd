extends Node

@export var _rb: RigidBody2D
@export var _crawl_speed: float
var _move_input: Vector2

func _ready() -> void:
	if _rb == null:
		printerr('crawl: rb is null')
		return


func _on_move_input_change(move_input: Vector2) -> void:
	_move_input = move_input


func _physics_process(delta: float) -> void:

	var horizontal = _move_input - Vector2(0, _move_input.y)
	var crawl_vector = horizontal.rotated(_rb.rotation)

	# Only move and collide when input is given
	if crawl_vector.length() == 0:
		return

	_rb.move_and_collide(crawl_vector * _crawl_speed * delta)
