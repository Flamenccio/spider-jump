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
		if _raycast_query != null:
			_raycast_query.collision_mask = value
		_current_climbable_layers = value
	get:
		return _current_climbable_layers

var _raycast_query: RaycastQuery

@export var _player: CharacterBody2D
@export_flags_2d_physics var _ground_layer: int
@export_flags_2d_physics var _slip_layer: int

func _ready() -> void:

	_current_climbable_layers = _ground_layer
	PlayerEventBus.powerup_started.connect(_on_powerup_started)
	PlayerEventBus.powerup_ended.connect(_on_powerup_ended)
	PlayerEventBus.player_collision_enter.connect(_on_player_collided)

	# Set up raycast
	_raycast_query = RaycastQuery.new()
	_raycast_query.collision_mask = _current_climbable_layers
	_raycast_query.source = _player


func _is_below_player(point: Vector2, normal: Vector2) -> bool:

	# If sideways, it cannot be below player
	if abs(normal.x) > 0.0:
		return false

	var current_gravity = GameConstants.current_gravity

	if current_gravity == 0:
		return true
	elif current_gravity > 0: # Falling
		return point.y > _player.global_position.y
	elif current_gravity < 0: # Rising
		return point.y < _player.global_position.y

	return false


func _on_ground_exited(body: Node2D) -> void:
	if _current_surface == null:
		return
	var surface_layer := 0
	if body is TileMapLayer:
		var tilemap_layers = body.tile_set.get_physics_layer_collision_layer(0)
		surface_layer = tilemap_layers & _ground_layer | tilemap_layers & _slip_layer
	elif body is CollisionObject2D:
		surface_layer = body.collision_layer
	else:
		return
	if _current_surface.surface_type == surface_layer:
		_current_surface = null
		leave_ground.emit()


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


func _on_player_collided(collision: KinematicCollision2D) -> void:
	_handle_collision(collision)


func _handle_collision(collision: KinematicCollision2D) -> void:

	# Handle collision
	var collider = collision.get_collider()

	if collider is TileMapLayer:
		_collide_with_tile_map_layer(collider, collision)
	elif collider is CollisionObject2D:
		_collide_with_collision_object(collider, collision)


func _collide_with_collision_object(obj: CollisionObject2D, collision: KinematicCollision2D) -> void:
	var new_surface := SurfaceInfo.new(collision.get_normal(), obj.collision_layer, collision.get_position())
	if _surface_is_same(_current_surface, new_surface):
		return
	_handle_surface(new_surface)


func _collide_with_tile_map_layer(tilemap: TileMapLayer, collision: KinematicCollision2D) -> void:
	var tilemap_layers = tilemap.tile_set.get_physics_layer_collision_layer(0)
	var surface_type = tilemap_layers & _ground_layer | tilemap_layers & _slip_layer
	var new_surface := SurfaceInfo.new(collision.get_normal(), surface_type, collision.get_position())
	if _surface_is_same(_current_surface, new_surface):
		return
	_handle_surface(new_surface)


func _handle_surface(new_surface: SurfaceInfo) -> void:

	# Handle ground surfaces
	if new_surface.surface_type == _ground_layer:
		# Do not update normal when hoverfly
		if GameConstants.current_powerup != ItemIds.HOVERFLY_POWERUP:
			pass
			land_on_normal.emit(new_surface.normal)
		land_on_ground.emit()
		_update_current_surface_info(new_surface)

	# Handle slippery surfaces
	elif new_surface.surface_type == _slip_layer:
		if GameConstants.current_powerup == ItemIds.HEAVY_BEETLE_POWERUP:
			land_on_normal.emit(new_surface.normal)
			land_on_slip.emit()
			_update_current_surface_info(new_surface)
		else:
			# Add to surfaces if in direction of player gravity
			if _is_below_player(new_surface.contact_point, new_surface.normal):
				land_on_normal.emit(new_surface.normal)
				land_on_slip.emit()
				_update_current_surface_info(new_surface)


class SurfaceInfo:

	func _init(set_normal: Vector2, set_surface_type: int, set_contact_point: Vector2) -> void:
		normal = set_normal
		surface_type = set_surface_type
		contact_point = set_contact_point

	var normal := Vector2.ZERO ## Normal vector of the surface
	var surface_type: int ## Type of the surface (slip/ground); uses the collision layer
	var contact_point: Vector2
