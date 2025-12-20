extends Node
"""
Saves the last place the player was standing
"""

signal player_recovered()

const _SEARCH_SPAN_HEIGHT = 8.0
const _SEARCH_SPAN_WIDTH = 112.0
const _MAX_SEARCHES = 20
const _INVALID_RAY_DISTANCE = 999999.0

## Dictionary of player info at recovery point.[br]
## Keys:[br]
## - [code]position[/code]: position of recovery point[br]
## - [code]rotation[/code]: rotation of player at recovery point[br]
## - [code]surface_info[/code]: GroundHandler surface info for surface at recovery
## point[br]
var recovery_info := {}

var _saved_surface_info: GroundHandler.SurfaceInfo
var _recovery_point_in_screen := true
var _shape_cast: ShapecastQuery
var _ray_cast: RaycastQuery

@export var _player: CharacterBody2D
@export var _shape_cast_shape: Shape2D

@export_flags_2d_physics var _danger_layers: int
@export_flags_2d_physics var _slippery_layers: int
@export_flags_2d_physics var _climbable_layers: int

func _ready() -> void:

	# Create shapecasts
	_shape_cast = ShapecastQuery.new()
	_shape_cast.collision_mask = 0
	_shape_cast.shape = _shape_cast_shape
	_shape_cast.source = _player

	# Create raycasts
	_ray_cast = RaycastQuery.new()
	_ray_cast.collision_mask = 0
	_ray_cast.source = _player
	
	# Connect signals
	PlayerEventBus.player_fell.connect(_on_player_fell)


func _update_recovery(force: bool = false) -> void:
	
	if GameConstants.recovery_point == null:
		push_warning("Unable to save state: recovery point is null")
		return

	_connect_recovery_point_signals()
	var rounded_position = Vector2(roundf(_player.global_position.x), roundf(_player.global_position.y))

	# Check area for danger (spikes)
	_shape_cast.collision_mask = _danger_layers
	var danger := _shape_cast.shapecast_query(rounded_position, rounded_position)
	if not danger.is_empty() and not force:
		return

	# Check if area is on the ground
	_shape_cast.collision_mask = _climbable_layers
	var climbable := _shape_cast.shapecast_query(rounded_position, rounded_position)
	if climbable.is_empty() and not force:
		return

	# Update recovery info
	_update_recovery_info()


func _update_recovery_info() -> void:
	recovery_info.set("position", _player.global_position)
	recovery_info.set("rotation", _player.rotation)
	recovery_info.set("surface_info", _saved_surface_info)
	GameConstants.recovery_info.assign(recovery_info)
	GameConstants.recovery_point.global_position = _player.global_position


func _on_player_fell(here: Vector2) -> void:
	if not _recovery_point_in_screen:
		_create_new_recovery_spot(here)
	player_recovered.emit()


func _connect_recovery_point_signals() -> void:
	if GameConstants.recovery_point == null:
		return
	var recovery_point := GameConstants.recovery_point
	if not recovery_point.screen_entered.is_connected(_recovery_point_enter_screen):
		recovery_point.screen_entered.connect(_recovery_point_enter_screen)
	if not recovery_point.screen_exited.is_connected(_recovery_point_exit_screen):
		recovery_point.screen_exited.connect(_recovery_point_exit_screen)


func _recovery_point_exit_screen() -> void:
	_recovery_point_in_screen = false


func _recovery_point_enter_screen() -> void:
	_recovery_point_in_screen = true


## Called when the the player's safe spot is off screen.
## Places a new safespot nearest to where the player died.
func _create_new_recovery_spot(died_here: Vector2) -> void:

	# Find where player died
	var screen_size := get_viewport().get_visible_rect().size
	var horizontal := died_here.x
	var camera_2d := get_viewport().get_camera_2d()
	var vertical := (camera_2d.get_canvas_transform().affine_inverse() * screen_size).y
	var iteration = 1

	while iteration < _MAX_SEARCHES:
		if _find_new_recovery_point(horizontal, vertical, iteration):
			return
		iteration += 1
	push_error("Unable to find recovery point")


func _find_new_recovery_point(horizontal: float, vertical: float, iteration: int) -> bool:

	var start = Vector2(horizontal, vertical - (_SEARCH_SPAN_HEIGHT * (iteration + 1)))
	var left_search = _search_direction(Vector2.LEFT, start)
	var right_search = _search_direction(Vector2.RIGHT, start)

	# Decide which side to use, or to scan another line above
	var best_result := _decide_safe_spot(left_search, right_search)
	if best_result == null:
		return false

	# Choose spot
	var side_multiplier := -1 if best_result == left_search else 1
	var new_safe_spot = start + Vector2(side_multiplier * best_result.distance, 0.0)
	var new_surface_info := GroundHandler.SurfaceInfo.new(best_result.normal, 0, Vector2.ZERO)

	# Update recovery info
	recovery_info.set("surface_info", new_surface_info)
	recovery_info.set("position", new_safe_spot)
	recovery_info.set("rotation", Vector2.UP.angle_to(best_result.normal))
	GameConstants.recovery_point.global_position = new_safe_spot
	GameConstants.recovery_info.assign(recovery_info)

	return true


## Search in the [code]direction[/code] from [code]search_origin[/code] for a RecoveryPointSearchResults
## to determine the safe spot quality.
func _search_direction(direction: Vector2, search_origin: Vector2) -> RecoveryPointSearchResults:

	direction = direction.normalized()
	if direction == Vector2.ZERO:
		push_warning("Direction length is 0 (0,0)")
		return null

	var search_result := RecoveryPointSearchResults.new()

	# Find the distance to the closest wall
	_ray_cast.collision_mask = _climbable_layers | _slippery_layers
	var ray_target = search_origin + Vector2(_SEARCH_SPAN_WIDTH * sign(direction.x), 0.0)
	var distance_results = _ray_cast.raycast_query(search_origin, ray_target)
	search_result.distance = _INVALID_RAY_DISTANCE
	if distance_results.is_empty():
		return search_result

	search_result.distance = search_origin.distance_to(distance_results.get("position"))
	search_result.normal = distance_results.get("normal")
	var potential_position = distance_results.get("position")

	# Find any dangerous things around the potential recovery point
	_shape_cast.collision_mask = _danger_layers
	var danger_search_results = _shape_cast.shapecast_query(potential_position, potential_position)
	if not danger_search_results.is_empty():
		search_result.dangerous_item.assign(danger_search_results)
	
	# Find any slippery surfaces around potential recovery point
	_shape_cast.collision_mask = _slippery_layers
	var slippery_search_results = _shape_cast.shapecast_query(potential_position, potential_position)
	if not slippery_search_results.is_empty():
		search_result.slippery_surface.assign(slippery_search_results)

	# Find any climbable surfaces around potential recovery point
	_shape_cast.collision_mask = _climbable_layers
	var climbable_search_results = _shape_cast.shapecast_query(potential_position, potential_position)
	if not climbable_search_results.is_empty():
		search_result.climbable_surface.assign(climbable_search_results)

	return search_result


## Compares two recovery point search results and returns the best one, or [code]null[/code] if both are poor.
func _decide_safe_spot(search_result_a: RecoveryPointSearchResults, search_result_b: RecoveryPointSearchResults) -> RecoveryPointSearchResults:

	var danger_a = not search_result_a.dangerous_item.is_empty()
	var danger_b = not search_result_b.dangerous_item.is_empty()

	var slippery_a = not search_result_a.slippery_surface.is_empty()
	var slippery_b = not search_result_b.slippery_surface.is_empty()

	var climbable_a = not search_result_a.climbable_surface.is_empty()
	var climbable_b = not search_result_b.climbable_surface.is_empty()

	# Choose direction
	var valid_a := climbable_a and not danger_a and not slippery_a
	var valid_b := climbable_b and not danger_b and not slippery_b
	var closest_side := minf(search_result_a.distance, search_result_b.distance)

	if valid_a and not valid_b:
		return search_result_a
	elif valid_b and not valid_a:
		return search_result_b
	elif valid_a and valid_b:
		if closest_side == search_result_a.distance:
			return search_result_a
		elif closest_side == search_result_b.distance:
			return search_result_b

	return null


func _on_surface_info_updated(new_surface_info: GroundHandler.SurfaceInfo) -> void:
	if new_surface_info != null:
		_saved_surface_info = new_surface_info


class RecoveryPointSearchResults:
	var distance := 0.0
	var dangerous_item: Dictionary
	var slippery_surface: Dictionary
	var climbable_surface: Dictionary
	var normal := Vector2.ZERO
