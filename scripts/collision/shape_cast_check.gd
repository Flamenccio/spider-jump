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


## Immediately sweeps an area described by `motion` from assigned origin Node2D.
func intersect_shape(motion: Vector2, max_results: int = 32) -> Array[Dictionary]:
	_shape_cast_query.motion = motion
	_shape_cast_query.transform.origin = _shape_cast_origin.global_position
	var space_state = _shape_cast_origin.get_world_2d().direct_space_state
	return space_state.intersect_shape(_shape_cast_query, max_results)


## Immediately sweeps an area described by `motion` starting from `origin_override`.
func intersect_shape_override_origin(motion: Vector2, origin_override: Vector2, max_results: int = 32) -> Array[Dictionary]:
	_shape_cast_query.motion = motion
	_shape_cast_query.transform.origin = origin_override
	var space_state = _shape_cast_origin.get_world_2d().direct_space_state

	return space_state.intersect_shape(_shape_cast_query, max_results)

