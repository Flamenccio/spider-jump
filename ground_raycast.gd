extends Node

signal change_player_rotation(normal: Vector2)

@export_flags_2d_physics var _raycast_layer: int
@export var _raycast_source: RigidBody2D
var _raycast_query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.new()

func _ready() -> void:
	_raycast_query.collision_mask = _raycast_layer


func _on_ground_detector_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is StaticBody2D:
		var col_obj := body as StaticBody2D
		var colliding_body := col_obj.shape_owner_get_owner(body_shape_index)
		_raycast(colliding_body)


func _raycast(body: Node2D) -> void:
	_raycast_query.from = _raycast_source.global_position
	_raycast_query.to = body.global_position
	var space_state = _raycast_source.get_world_2d().direct_space_state
	var results := space_state.intersect_ray(_raycast_query)

	if not results.keys().has('normal'):
		return

	change_player_rotation.emit(results['normal'])
