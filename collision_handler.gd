extends Node

@export var _ground_raycast: RaycastCheck
@export var _ground_shapecast: ShapeCastCheck
@export var _player: Node2D

signal land_on_normal(normal: Vector2)
signal land_on_ground()
signal land_on_slip()
signal leave_ground()

# Grounds the player is currently touching
var _ground_contacts: Array[Node]

@export_flags_2d_physics var _ground_layer: int
@export_flags_2d_physics var _slip_layer: int
@export var _ground_shapecast_direction: Vector2


# Used by rigidbodies
func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:

	# Ground
	if _is_on_collision_layer(body, _ground_layer):
		if _track_ground(body):
			land_on_ground.emit()
			_find_normal(body, body_shape_index)

	# Look for slippery ground below; add if there is any
	var max_results = 1
	var results := _ground_shapecast.intersect_shape(_ground_shapecast_direction, max_results, false)
	if results.size() > 0:
		var collider = results[0]['collider']
		print('result: ', collider)
		if _is_on_collision_layer(collider, _slip_layer):
			if _track_ground(collider):
				land_on_slip.emit()


func _on_body_shape_exited(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if _untrack_ground(body):
		if _ground_contacts.size() == 0:
			leave_ground.emit()


func _find_normal(body: Node, body_shape_index: int) -> void:
	if body is StaticBody2D:
		var col_obj := body as StaticBody2D
		var colliding_body := col_obj.shape_owner_get_owner(body_shape_index)
		var raycast_results := _ground_raycast.intersect_ray(colliding_body.global_position)
		if raycast_results.keys().has('normal'):
			land_on_normal.emit(raycast_results['normal'])


func _is_on_collision_layer(node: Node, layer: int) -> bool:
	return node.collision_layer & layer > 0


func _track_ground(ground: Node) -> bool:
	if not _ground_contacts.has(ground):
		_ground_contacts.push_back(ground)
		return true
	return false


func _untrack_ground(ground: Node) -> bool:
	if not _ground_contacts.has(ground):
		return false
	_ground_contacts.erase(ground)
	return true
