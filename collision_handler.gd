extends Node

signal set_state_machine_condition(condition: String, value)
signal land_on_normal(normal: Vector2)
@export var _ground_raycast: RaycastCheck


func _on_ground_detector_body_exited(body:Node2D) -> void:
	set_state_machine_condition.emit('ground', false)


func _on_ground_detector_body_entered(body:Node2D) -> void:
	set_state_machine_condition.emit('ground', true)


func _on_ground_detector_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is StaticBody2D:
		var col_obj := body as StaticBody2D
		var colliding_body := col_obj.shape_owner_get_owner(body_shape_index)
		var raycast_results := _ground_raycast.intersect_ray(colliding_body.global_position)
		if raycast_results.keys().has('normal'):
			land_on_normal.emit(raycast_results['normal'])


func _on_slip_detector_body_exited(body:Node2D) -> void:
	set_state_machine_condition.emit('slippery', false)


func _on_slip_detector_body_entered(body:Node2D) -> void:
	set_state_machine_condition.emit('slippery', true)
