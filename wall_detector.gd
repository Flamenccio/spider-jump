extends Area2D

@export_group('Raycasting')
@export var _player: Node2D
@export_flags_2d_physics var _raycast_layer


signal hit_wall()
signal leave_wall()
signal collision_normal(normal: Vector2)

var _raycast_query: PhysicsRayQueryParameters2D

func _ready() -> void:
	_raycast_query = PhysicsRayQueryParameters2D.new()
	_raycast_query.collision_mask = _raycast_layer


func _on_body_entered(body:Node2D) -> void:
	hit_wall.emit()
	_get_collision_normal(body)


func _on_body_exited(body:Node2D) -> void:
	leave_wall.emit()


func _get_collision_normal(body: Node2D) -> void:

	# Fire raycast from player to body
	_raycast_query.from = _player.global_position
	_raycast_query.to = body.global_position

	var space_state := _player.get_world_2d().direct_space_state
	var collision := space_state.intersect_ray(_raycast_query)

	if collision.size() == 0:
		return

	collision_normal.emit(collision['normal'])
