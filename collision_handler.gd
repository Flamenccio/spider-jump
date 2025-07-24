extends Node

@export var _ground_raycast: RaycastCheck
@export var _ground_shapecast: ShapeCastCheck
@export var _player: Node2D

signal land_on_normal(normal: Vector2)
signal land_on_ground()
signal land_on_slip()
signal leave_ground()
signal eat_fly(stamina_restore: float)
signal danger_entered()

# Grounds the player is currently touching
var _ground_contacts: Array[Node]
var ground_contacts: Array[Node]:
	get:
		return _ground_contacts
	set(value):
		return

@export_flags_2d_physics var _ground_layer: int
@export_flags_2d_physics var _slip_layer: int
@export var _ground_raycast_direction: Vector2

class SurfaceContacts:
	var node: Node
	var shape_index: int

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int) -> void:

	var shape_owner = body.shape_owner_get_owner(body_shape_index)

	# Ground
	if _is_on_collision_layer(body, _ground_layer):
		if _track_ground(shape_owner):
			land_on_ground.emit()
			_find_normal(body, body_shape_index)
	
	_search_for_slip(body, body_shape_index)


func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int) -> void:
	var shape_owner = body.shape_owner_get_owner(body_shape_index)
	if _untrack_ground(shape_owner):
		if _ground_contacts.size() == 0:
			leave_ground.emit()


func _find_normal(body: Node, body_shape_index: int) -> void:
	"""
	if body is StaticBody2D:
		var col_obj := body as StaticBody2D
		var colliding_body := col_obj.shape_owner_get_owner(body_shape_index)
		var raycast_results := _ground_raycast.intersect_ray(colliding_body.global_position)
		if raycast_results.keys().has('normal'):
			land_on_normal.emit(raycast_results['normal'])
	"""
	_find_normal_with_shape(body, body.shape_owner_get_owner(body_shape_index))


func _find_normal_with_shape(body: Node, body_shape: Node) -> void:
	var raycast_results := _ground_raycast.intersect_ray(body_shape.global_position)
	if raycast_results.keys().has('normal'):
		land_on_normal.emit(raycast_results['normal'])


func _recalculate_normal() -> void:
	if _ground_contacts.size() == 0:
		return
	var latest_surface = _ground_contacts[0]
	var body = latest_surface.get_parent()
	_find_normal_with_shape(body, latest_surface)


func _is_on_collision_layer(node: Node, layer: int) -> bool:
	return node.collision_layer & layer > 0


func _track_ground(ground: Node) -> bool:
	if not _ground_contacts.has(ground):
		_ground_contacts.push_front(ground)
		return true
	return false


func _untrack_ground(ground: Node) -> bool:
	if not _ground_contacts.has(ground):
		return false
	_ground_contacts.erase(ground)
	return true


# Look for slippery ground below; add if there is any
func _search_for_slip(body: Node2D, shape_index: int) -> void:

	if not _is_on_collision_layer(body, _slip_layer):
		return
	
	var max_results = 4
	var shapecast_results := _ground_shapecast.intersect_shape(_ground_raycast_direction, max_results, false)
	
	if shapecast_results.size() == 0:
		return

	# Search for slippery ground in results
	for result in shapecast_results:
		var result_collider = result['collider']
		if _is_on_collision_layer(result_collider, _slip_layer):
			var collision_shape = result_collider.shape_owner_get_owner(shape_index)
			if _track_ground(collision_shape):
				land_on_slip.emit()


func _on_item_collided(body: Node2D) -> void:
	if body is not Item:
		return
	var item := body as Item
	_handle_item(item)
	body.queue_free()


func _on_danger_entered(body: Node2D) -> void:
	danger_entered.emit()


func _handle_item(item: Item) -> void:
	match item.item_id:
		'yum_fly':
			eat_fly.emit(0.25)
		_:
			printerr('item handler: unknown item id "{0}"'.format({'0': item.item_id}))
			print('oops!')
