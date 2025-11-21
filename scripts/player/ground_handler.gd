extends Node

@export var _raycaster: Raycaster
@export_flags_2d_physics var _ground_layer: int
@export_flags_2d_physics var _slip_layer: int

signal land_on_normal(normal: Vector2)
signal land_on_ground()
signal land_on_slip()
signal leave_ground()

# Grounds the player is currently touching
var _surface_contacts: Array[Node]
var surface_contacts: Array[Node]:
	get:
		return _surface_contacts
	set(value):
		return

var _current_climbable_layers: int = 0

func _ready() -> void:
	_current_climbable_layers = _ground_layer
	PlayerEventBus.powerup_started.connect(_on_powerup_started)
	PlayerEventBus.powerup_ended.connect(_on_powerup_ended)


func _on_ground_enter(body_rid: RID, body: Node2D, body_shape_index: int) -> void:

	var shape_owner = body.shape_owner_get_owner(body_shape_index)
	var slip_ground_enabled = GameConstants.current_powerup == ItemIds.HEAVY_BEETLE_POWERUP and _is_on_collision_layer(body, _slip_layer)

	# Ground
	if _is_on_collision_layer(body, _ground_layer) or slip_ground_enabled:
		if _track_ground(shape_owner):

			# Do not rotate towards normal when hoverfly powerup
			if GameConstants.current_powerup != ItemIds.HOVERFLY_POWERUP:
				_update_current_surface_normal(body.shape_owner_get_owner(body_shape_index))
	
	# Slip
	if GameConstants.current_powerup != ItemIds.HEAVY_BEETLE_POWERUP:
		_search_for_slip(body, body_shape_index)


func _on_ground_exited(body_rid: RID, body: Node2D, body_shape_index: int) -> void:
	var shape_owner = body.shape_owner_get_owner(body_shape_index)
	if _untrack_ground(shape_owner):
		if _surface_contacts.size() == 0:
			leave_ground.emit()


func _calculate_normal_to(position: Vector2, target_layers: int) -> Vector2:

	var raycast_query = PhysicsRayQueryParameters2D.new()
	raycast_query.from = _raycaster.raycast_source.global_position
	raycast_query.to = position
	raycast_query.collision_mask = target_layers
	var results = _raycaster.intersect_ray(raycast_query)

	if results.size() == 0:
		return Vector2.ZERO

	return results['normal']


## Update the current surface normal to surface `surface_node`.
## If `surface_node` is null, instead finds the normal to the latest surface the player
## touched.
func _update_current_surface_normal(surface_node: Node) -> void:

	if surface_node == null:
		if _surface_contacts.size() == 0:
			return
		surface_node = _surface_contacts[0]

	var normal = _calculate_normal_to(surface_node.global_position, _current_climbable_layers)

	if normal != Vector2.ZERO:
		land_on_normal.emit(normal)


## Calculates and updates the current surface normal to the latest
## surface the player touched.
func _recalculate_normal() -> void:
	_update_current_surface_normal(null)


func _is_on_collision_layer(node: Node, layer: int) -> bool:
	if node is CollisionShape2D:
		return node.get_parent().collision_layer & layer > 0
	return node.collision_layer & layer > 0


func _track_ground(ground: Node) -> bool:
	if not _surface_contacts.has(ground):
		_surface_contacts.push_front(ground)
		_update_ground_type()
		return true
	return false


func _untrack_ground(ground: Node) -> bool:
	if not _surface_contacts.has(ground):
		_update_ground_type()
		return false
	_surface_contacts.erase(ground)
	return true


## Stand on slippery ground below (or above, depending on gravity)
func _search_for_slip(body: Node2D, shape_index: int) -> void:

	if not _is_on_collision_layer(body, _slip_layer):
		return
	
	var collider = body.shape_owner_get_owner(shape_index)
	var shape = body.shape_owner_get_shape(shape_index, 0) as Shape2D
	
	if shape is not RectangleShape2D:
		return

	var rect = shape as RectangleShape2D
	var top = collider.global_position.y - (rect.size.y / 2.0)

	if _raycaster.raycast_source.global_position.y <= top:
		if _track_ground(collider):
			land_on_normal.emit(Vector2.UP)


func _on_powerup_started(powerup: String) -> void:
	match powerup:
		ItemIds.HOVERFLY_POWERUP:
			land_on_normal.emit(Vector2.UP)
		ItemIds.HEAVY_BEETLE_POWERUP:
			_current_climbable_layers = _ground_layer | _slip_layer


func _on_powerup_ended(powerup: String) -> void:
	match powerup:
		ItemIds.HEAVY_BEETLE_POWERUP:
			_current_climbable_layers = _ground_layer


func _on_player_jumped() -> void:
	# Clear ground contacts
	_surface_contacts.clear()
	leave_ground.emit()


# Sets the ground type depending on all surface contacts
func _update_ground_type() -> void:

	"""
	- If there are no surface contacts (the array is empty),
	then the surface type is AIR
	- If the only type of surface currently in contact is SLIP,
	then the surface type is SLIP
	- Otherwise, if there is at least one GROUND surface, the surface
	type is GROUND
	"""

	# Set AIR surface
	if _surface_contacts.size() == 0:
		leave_ground.emit()
		return

	var surface_type_count = func(accum, surface, layer):
		if _is_on_collision_layer(surface, layer):
			return accum + 1
		return accum

	var slip_count = _surface_contacts.reduce(surface_type_count.bind(_slip_layer), 0)
	var ground_count = _surface_contacts.reduce(surface_type_count.bind(_ground_layer), 0)

	# Set SLIP surface
	if slip_count > 0 and ground_count == 0:
		land_on_slip.emit()
		return

	# Set GROUND surface
	if ground_count > 0:
		land_on_ground.emit()
		return
