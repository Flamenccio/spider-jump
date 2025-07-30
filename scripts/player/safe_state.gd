extends Node
"""
Saves the last place the player was standing
"""

signal safe_spot_updated(pos: Vector2)
signal player_recovered()

@export var _player: CharacterBody2D
@export var _danger_shapecast: ShapeCastCheck
@export var _safe_spot_shapecast: ShapeCastCheck
@export var _safe_spot_distance_raycast: RaycastCheck

@export_flags_2d_physics var _danger_layers: int
@export_flags_2d_physics var _slippery_layers: int
@export_flags_2d_physics var _climbable_layers: int

var _position: Vector2
var _rotation: float
var _safe_spot_in_screen: bool
var _closest_distance: float

const _MAX_SHAPECAST_RESULTS = 1
const _MAX_SEARCH_SHAPECAST_RESULTS = 3
const _SEARCH_SPAN_HEIGHT = 8.0
const _SEARCH_SPAN_WIDTH = 112.0
const _MAX_SEARCHES = 20

func _save_state() -> void:
	var rounded_position = Vector2(roundf(_player.global_position.x), roundf(_player.global_position.y))

	# Check area for danger (spikes)
	var results := _danger_shapecast.intersect_shape(Vector2.ZERO, _MAX_SHAPECAST_RESULTS)
	if results.size() > 0:
		print('danger!!')
		return

	_position = rounded_position
	_rotation = _player.rotation
	safe_spot_updated.emit(_position)


func _on_player_fell(here: Vector2) -> void:
	if not _safe_spot_in_screen:
		_recover_safe_spot(here)
	_player.global_position = _position
	_player.rotation = _rotation
	_player.velocity = Vector2.ZERO
	player_recovered.emit()


func _safe_spot_updated(in_screen: bool) -> void:
	_safe_spot_in_screen = in_screen
	if not _safe_spot_in_screen:
		print('safe spot is not safe!!!!')
	else:
		print('never mind!!!')


## Called when the the player's safe spot is off screen.
## Places a new safespot nearest to where the player died.
func _recover_safe_spot(died_here: Vector2) -> void:

	# Find where player died
	var screen_size := get_viewport().get_visible_rect().size
	var horizontal := died_here.x
	var camera_2d := get_viewport().get_camera_2d()
	var vertical := (camera_2d.get_canvas_transform().affine_inverse() * screen_size).y
	var iteration = 1
	while iteration < _MAX_SEARCHES:
		if _recover_safe_spot_loop(horizontal, vertical, iteration):
			return
		iteration += 1


func _recover_safe_spot_loop(horizontal: float, vertical: float, iteration: int) -> bool:

	var start = Vector2(horizontal, vertical - (_SEARCH_SPAN_HEIGHT * (iteration + 1)))

	# Raycast to find closest wall
	var raycast_offset = Vector2(_SEARCH_SPAN_WIDTH, 0.0)
	var raycast_target_right = start + raycast_offset
	var raycast_target_left = start - raycast_offset
	var raycast_result_right = _safe_spot_distance_raycast.intersect_ray(raycast_target_right)
	var raycast_result_left = _safe_spot_distance_raycast.intersect_ray(raycast_target_left)
	var right_distance = _get_raycast_distance(_safe_spot_distance_raycast, raycast_result_right)
	var left_distance = _get_raycast_distance(_safe_spot_distance_raycast, raycast_result_left)
	var right_hit_point = raycast_result_right['position']
	var left_hit_point = raycast_result_left['position']

	# Shapecast both sides
	var shapecast_motion = Vector2(0.0, 0.0)
	var shapecast_results_right = _safe_spot_shapecast.intersect_shape_override_origin(shapecast_motion, right_hit_point, _MAX_SHAPECAST_RESULTS)
	var shapecast_results_left = _safe_spot_shapecast.intersect_shape_override_origin(shapecast_motion, left_hit_point, _MAX_SHAPECAST_RESULTS)

	# Decide which side to use, or to scan another line above
	var side := _decide_safe_spot(shapecast_results_right, shapecast_results_left, right_distance, left_distance)

	var new_surface_normal := Vector2.ZERO

	# If both sides are poor, move up and scan again
	if side == 0:
		return false
	# Otherwise set normal
	elif side == -1:
		new_surface_normal = raycast_result_left['normal']
	elif side == 1:
		new_surface_normal = raycast_result_right['normal']

	# Otherwise choose spot
	var new_safe_spot = start + Vector2(side * _closest_distance, 0)
	_position = new_safe_spot
	_rotation = Vector2.UP.angle_to(new_surface_normal)
	safe_spot_updated.emit(new_safe_spot)

	return true


## Returns `1` if **right side** is used, `-1` if **left side** is used, or `0` if **neither side** is valid.
func _decide_safe_spot(shapecast_right: Array[Dictionary], shapecast_left: Array[Dictionary], right_distance: float, left_distance: float) -> int:

	# Search for danger
	var left_danger = _shapecast_results_has_layers(shapecast_left, _danger_layers)
	var right_danger = _shapecast_results_has_layers(shapecast_right, _danger_layers)

	# Search for slippery ground
	var left_slippery = _shapecast_results_has_layers(shapecast_left, _slippery_layers)
	var right_slippery = _shapecast_results_has_layers(shapecast_right, _slippery_layers)

	# Search for climbable ground
	var left_ground = _shapecast_results_has_layers(shapecast_left, _climbable_layers)
	var right_ground = _shapecast_results_has_layers(shapecast_right, _climbable_layers)

	# Choose direction
	var left_valid := left_ground and not left_danger and not left_slippery
	var right_valid := right_ground and not right_danger and not right_slippery
	var closest_side := minf(left_distance, right_distance)
	_closest_distance = closest_side

	if left_valid and not right_valid:
		return -1
	elif right_valid and not left_valid:
		return 1
	elif left_valid and right_valid:
		if closest_side == left_distance:
			return -1
		elif closest_side == right_distance:
			return 1

	return 0


func _shapecast_results_has_layers(shapecast_results: Array[Dictionary], layers: int) -> bool:
	if shapecast_results.size() == 0:
		return false
	for result in shapecast_results:
		if _collider_is_on_layer(result['collider'], layers):
			return true
	return false


func _collider_is_on_layer(collider: Variant, layer: int) -> bool:
	# Handle each type of collider
	if collider is CollisionObject2D:
		var obj = collider as CollisionObject2D
		if obj.collision_layer & layer > 0:
			return true
	elif collider is TileMapLayer:
		var tml = collider as TileMapLayer
		# NOTE: I'm gonna assume that a tilemaplayer has only one physics layer
		# might have to change this maybe
		var tileset = tml.tile_set
		var tile_layer = tileset.get_physics_layer_collision_layer(0)
		if tile_layer & layer > 0:
			return true
	else:
		printerr('safe state: type {0} not handled!'.format({'0': typeof(collider)}))

	return false


func _get_raycast_distance(raycast_check: RaycastCheck, raycast_results: Dictionary) -> float:
	if raycast_results.size() == 0:
		# Return a really big number
		return 999999.0
	var origin = raycast_check.raycast_source.global_position
	var intersection_point = raycast_results['position'] as Vector2
	return origin.distance_to(intersection_point)

