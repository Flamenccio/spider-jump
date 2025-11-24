extends Node

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

var _current_surface: SurfaceInfo
var _surfaces: Array[SurfaceInfo]
var _current_climbable_layers: int = 0

@export var _tilemap_shapecast: ShapeCast2D
@export var _raycaster: Raycaster
@export_flags_2d_physics var _ground_layer: int
@export_flags_2d_physics var _slip_layer: int

func _ready() -> void:
	_tilemap_shapecast.collision_mask = _ground_layer
	_current_climbable_layers = _ground_layer
	PlayerEventBus.powerup_started.connect(_on_powerup_started)
	PlayerEventBus.powerup_ended.connect(_on_powerup_ended)


func _on_ground_enter(body_rid: RID, body: Node2D, body_shape_index: int) -> void:

	print("enter: ", body)

	# Check tilemap caster
	var info = _tilemap_shapecast.get_closest_collision_info()
	if info.is_empty():
		return

	var surface_group := 0

	# Determine surface group
	if body is TileMapLayer:
		if _tilemap_is_on_physics_layer(body, _ground_layer):
			surface_group = _ground_layer
		elif _tilemap_is_on_physics_layer(body, _slip_layer):
			surface_group = _slip_layer
	else:
		surface_group = body.collision_layer

	"""
	# Check if the player is on like surfaces; only add new surfaces
	var new_surface = SurfaceInfo.new(info.get("normal"), surface_group, body_rid)
	if _surfaces.any(_surface_is_same.bind(new_surface)):
		return
	"""
	var new_surface = SurfaceInfo.new(info.get("normal"), surface_group, info.get("point"))
	if _surface_is_same(_current_surface, new_surface):
		return

	# Handle ground surfaces
	if surface_group == _ground_layer:
		# Do not update normal when hoverfly
		if GameConstants.current_powerup != ItemIds.HOVERFLY_POWERUP:
			land_on_normal.emit(new_surface.normal)
			print("NORMAL: ", new_surface.normal)
		#_surfaces.push_front(new_surface)
		land_on_ground.emit()
		_current_surface = new_surface

	# Handle slippery surfaces
	elif surface_group == _slip_layer:
		if GameConstants.current_powerup == ItemIds.HEAVY_BEETLE_POWERUP:
			land_on_normal.emit(new_surface.normal)
			print("NORMAL: ", new_surface.normal)
			#_surfaces.push_front(new_surface)
			land_on_slip.emit()
			_current_surface = new_surface
		else:
			# Add to surfaces if in direction of player gravity
			if _is_below_player(body):
				land_on_normal.emit(new_surface.normal)
				print("NORMAL: ", new_surface.normal)
				land_on_slip.emit()
				#_surfaces.push_front(new_surface)
				_current_surface = new_surface


func _tilemap_is_on_physics_layer(tilemap: TileMapLayer, layer: int) -> bool:
	var tile_set = tilemap.tile_set
	var physics_layers = tile_set.get_physics_layers_count()
	for p in physics_layers:
		if tile_set.get_physics_layer_collision_layer(p) & layer > 0:
			return true
	return false


func _is_below_player(node: Node2D) -> bool:

	var current_gravity = GameConstants.current_gravity
	var player = GameConstants.player

	if current_gravity == 0:
		return true
	elif current_gravity > 0: # Falling
		return node.global_position.y > player.global_position.y
	elif current_gravity < 0: # Rising
		return node.global_position.y < player.global_position.y

	return false


func _on_ground_exited(body_rid: RID, body: Node2D, body_shape_index: int) -> void:
	pass


func _calculate_normal_to(position: Vector2, target_layers: int) -> Vector2:

	var raycast_query = PhysicsRayQueryParameters2D.new()
	raycast_query.from = _raycaster.raycast_source.global_position
	raycast_query.to = position
	raycast_query.collision_mask = target_layers
	var results = _raycaster.intersect_ray(raycast_query)

	if results.size() == 0:
		return Vector2.ZERO

	return results['normal']


## Calculates and updates the current surface normal to the latest
## surface the player touched.
func _recalculate_normal() -> void:
	#_update_current_surface_normal(null)
	if _current_surface == null:
		return
	var normal = _calculate_normal_to(_current_surface.contact_point, _current_climbable_layers)
	if normal != Vector2.ZERO:
		land_on_normal.emit(normal)


func _is_on_collision_layer(node: Node, layer: int) -> bool:
	if node is CollisionShape2D:
		return node.get_parent().collision_layer & layer > 0
	return node.collision_layer & layer > 0


func _on_powerup_started(powerup: String) -> void:
	match powerup:
		ItemIds.HOVERFLY_POWERUP:
			land_on_normal.emit(Vector2.UP)
		ItemIds.HEAVY_BEETLE_POWERUP:
			_current_climbable_layers = _ground_layer | _slip_layer
			_tilemap_shapecast.collision_mask = _current_climbable_layers


func _on_powerup_ended(powerup: String) -> void:
	match powerup:
		ItemIds.HEAVY_BEETLE_POWERUP:
			_current_climbable_layers = _ground_layer
			_tilemap_shapecast.collison_mask = _current_climbable_layers


func _on_player_jumped() -> void:
	# Clear ground contacts
	_surfaces.clear()
	_current_surface = null
	leave_ground.emit()


func _surface_is_same(surface_info_a: SurfaceInfo, surface_info_b: SurfaceInfo) -> bool:
	if surface_info_a == null or surface_info_b == null:
		return false
	return surface_info_a.normal == surface_info_b.normal and surface_info_a.surface_type == surface_info_b.surface_type


class SurfaceInfo:

	func _init(set_normal: Vector2, set_surface_type: int, set_contact_point: Vector2) -> void:
		normal = set_normal
		surface_type = set_surface_type
		contact_point = set_contact_point

	var normal := Vector2.ZERO ## Normal vector of the surface
	var surface_type: int ## Type of the surface (slip/ground); uses the collision layer
	var contact_point: Vector2
