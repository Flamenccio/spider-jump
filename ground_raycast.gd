class_name RaycastCheck
## Checks a raycast intersection with specific parameters on demand.
extends Node

@export_flags_2d_physics var _raycast_layer: int
@export var _raycast_source: Node2D
var _raycast_query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.new()

func _ready() -> void:
	_raycast_query.collision_mask = _raycast_layer


## Casts a ray from `_raycast_source` to `to`.
## Returns the results of the raycast.
func intersect_ray(to: Vector2) -> Dictionary:
	_raycast_query.from = _raycast_source.global_position
	_raycast_query.to = to
	var space_state = _raycast_source.get_world_2d().direct_space_state
	var results := space_state.intersect_ray(_raycast_query)
	return results
