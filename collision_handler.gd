extends Node

#signal set_state_machine_condition(condition: String, value)
signal land_on_normal(normal: Vector2)
signal land_on_ground()
signal land_on_slip()
signal leave_ground()
signal leave_slip()

@export var _ground_raycast: RaycastCheck
@export_flags_2d_physics var _ground_layer: int
@export_flags_2d_physics var _slip_layer: int

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	# Ground
	if body.collision_layer & _ground_layer > 0:
		land_on_ground.emit()
		_find_normal(body, body_shape_index)
	# Slippery ground
	elif body.collision_layer & _slip_layer > 0:
		land_on_slip.emit()


func _on_body_shape_exited(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	# Ground
	if body.collision_layer & _ground_layer > 0:
		leave_ground.emit()
	# Slippery ground
	elif body.collision_layer & _slip_layer > 0:
		leave_slip.emit()


func _find_normal(body: Node, body_shape_index: int) -> void:
	if body is StaticBody2D:
		var col_obj := body as StaticBody2D
		var colliding_body := col_obj.shape_owner_get_owner(body_shape_index)
		var raycast_results := _ground_raycast.intersect_ray(colliding_body.global_position)
		if raycast_results.keys().has('normal'):
			land_on_normal.emit(raycast_results['normal'])

