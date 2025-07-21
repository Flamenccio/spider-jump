class_name ShapeCastCheck
extends Node

@export var _shape: Shape2D
@export var _shape_cast_origin: Node2D
@export_flags_2d_physics var _shape_cast_layers: int
var _shape_cast_query: PhysicsShapeQueryParameters2D

func _ready() -> void:

	if _shape == null:
		printerr('shape cast check: shape is null')
		return

	_shape_cast_query = PhysicsShapeQueryParameters2D.new()
	_shape_cast_query.shape = _shape
	_shape_cast_query.collision_mask = _shape_cast_layers


func intersect_shape(motion: Vector2, max_results: int = 32, global: bool = true) -> Array[Dictionary]:
	
	# If global, counter-rotate against origin's rotation
	if global:
		var origin_rotation = _shape_cast_origin.rotation
		var global_motion = motion.rotated(-origin_rotation)
		motion = global_motion

	_shape_cast_query.motion = motion
	_shape_cast_query.transform.origin = _shape_cast_origin.global_position
	var space_state = _shape_cast_origin.get_world_2d().direct_space_state
	return space_state.intersect_shape(_shape_cast_query, max_results)

