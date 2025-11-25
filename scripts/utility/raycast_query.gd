class_name RaycastQuery

var source: Node2D
var collision_mask := 0

var _query: PhysicsRayQueryParameters2D

func _init() -> void:
	_query = PhysicsRayQueryParameters2D.new()


## Calls [code]intersect_ray[/code] using [code]source[/code] to access the
## direct space state, and returns the results.
func raycast_query(from: Vector2, to: Vector2) -> Dictionary:
	if source == null:
		push_warning("Source is null")
		return {}
	_query.from = from
	_query.to = to
	_query.collision_mask = collision_mask
	return source.get_world_2d().direct_space_state.intersect_ray(_query)
