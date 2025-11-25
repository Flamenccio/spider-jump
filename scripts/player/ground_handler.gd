extends Node

signal land_on_normal(normal: Vector2)
signal land_on_ground()
signal land_on_slip()
signal leave_ground()

const _MAX_SURFACE_HISTORY = 3

var _current_surface: SurfaceInfo

var _current_climbable_layers: int = 0:
	set(value):
		if value < 0:
			return
		if _tilemap_shapecast_query != null:
			_tilemap_shapecast_query.collision_mask = value
		if _raycast_query != null:
			_raycast_query.collision_mask = value
		_current_climbable_layers = value
	get:
		return _current_climbable_layers

var _tilemap_shapecast_query: ShapecastQuery
var _raycast_query: RaycastQuery

@export var _player: Node2D
@export var _tilemap_shapecast_shape: Shape2D
@export_flags_2d_physics var _ground_layer: int
@export_flags_2d_physics var _slip_layer: int

func _ready() -> void:

	_current_climbable_layers = _ground_layer
	PlayerEventBus.powerup_started.connect(_on_powerup_started)
	PlayerEventBus.powerup_ended.connect(_on_powerup_ended)

	# Set up shapecast
	if _tilemap_shapecast_shape == null:
		push_error("Tilemap shapecast shape not set")
		return

	_tilemap_shapecast_query = ShapecastQuery.new()
	_tilemap_shapecast_query.shape = _tilemap_shapecast_shape
	_tilemap_shapecast_query.collision_mask = _current_climbable_layers
	_tilemap_shapecast_query.source = _player

	# Set up raycast
	_raycast_query = RaycastQuery.new()
	_raycast_query.collision_mask = _current_climbable_layers
	_raycast_query.source = _player


func _on_ground_enter(body_rid: RID, body: Node2D, body_shape_index: int) -> void:

	var surface_group := 0

	# Determine surface group
	if body is TileMapLayer:
		if not TileMapUtilities.get_physics_layers_collision_layers(body, _ground_layer).is_empty():
			surface_group = _ground_layer
		elif not TileMapUtilities.get_physics_layers_collision_layers(body, _slip_layer).is_empty():
			surface_group = _slip_layer
	else:
		surface_group = body.collision_layer

	# Get shapecast result
	var shapecast_result = _tilemap_shapecast_query.shapecast_query(_player.global_position, _player.global_position)
	if shapecast_result.is_empty():
		return
	
	var new_surface = SurfaceInfo.new(shapecast_result.get("normal"), surface_group, shapecast_result.get("point"))

	# Handle ground surfaces
	if surface_group == _ground_layer:
		# Do not update normal when hoverfly
		if GameConstants.current_powerup != ItemIds.HOVERFLY_POWERUP:
			pass
			land_on_normal.emit(new_surface.normal)
		land_on_ground.emit()
		_update_current_surface_info(new_surface)

	# Handle slippery surfaces
	elif surface_group == _slip_layer:
		if GameConstants.current_powerup == ItemIds.HEAVY_BEETLE_POWERUP:
			land_on_normal.emit(new_surface.normal)
			land_on_slip.emit()
			_update_current_surface_info(new_surface)
		else:
			# Add to surfaces if in direction of player gravity
			if _is_below_player(body):
				land_on_normal.emit(new_surface.normal)
				land_on_slip.emit()
				_update_current_surface_info(new_surface)


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
	"""
	if _current_surface != null:
		_current_surface = null
		leave_ground.emit()
	"""
	pass


## Calculates and updates the current surface normal to the latest
## surface the player touched.
func _recalculate_normal() -> void:

	if _current_surface == null:
		return

	var results = _raycast_query.raycast_query(_player.global_position, _current_surface.contact_point)

	if results.is_empty():
		return

	var normal = results.get("normal")
	land_on_normal.emit(normal)


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
	_update_current_surface_info(null)
	leave_ground.emit()


func _surface_is_same(surface_info_a: SurfaceInfo, surface_info_b: SurfaceInfo) -> bool:
	if surface_info_a == null or surface_info_b == null:
		return false
	return surface_info_a.normal == surface_info_b.normal and surface_info_a.surface_type == surface_info_b.surface_type


func _update_current_surface_info(new_surface_info: SurfaceInfo) -> void:
	_current_surface = new_surface_info


class SurfaceInfo:

	func _init(set_normal: Vector2, set_surface_type: int, set_contact_point: Vector2) -> void:
		normal = set_normal
		surface_type = set_surface_type
		contact_point = set_contact_point

	var normal := Vector2.ZERO ## Normal vector of the surface
	var surface_type: int ## Type of the surface (slip/ground); uses the collision layer
	var contact_point: Vector2
