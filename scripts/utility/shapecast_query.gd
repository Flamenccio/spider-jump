class_name ShapecastQuery
## Performs shapecast queries with the Physics2D server
## and returns their results.

var shape: Shape2D
var collision_mask := 0
var source: Node2D
var _query: PhysicsShapeQueryParameters2D

func _init() -> void:
	_query = PhysicsShapeQueryParameters2D.new()


## Calls [code]get_rest_info[/code], using this class's properties as shape query parameters
## and returns the results.
func shapecast_query(from: Vector2, to: Vector2) -> Dictionary:

	if shape == null:
		push_warning("Shape not set")
		return {}
	if source == null:
		push_warning("Source not set")
		return {}

	var trans = Transform2D.IDENTITY

	trans.origin = from
	_query.transform = trans
	_query.shape = shape
	_query.collision_mask = collision_mask
	_query.motion = to - from

	return source.get_world_2d().direct_space_state.get_rest_info(_query)
