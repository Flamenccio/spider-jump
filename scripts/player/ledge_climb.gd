extends Node

signal climbed_around_ledge(climb_to: Vector2)
signal climb_started()

@export var _player: Node2D
@export var _ground_detector_l: ShapeCast2D
@export var _ground_detector_r: ShapeCast2D
@export var _raycaster: Raycaster

var _active_shapecast: ShapeCast2D
var active: bool = false
var _surface_point: Vector2
var _shapecast_radius: float

const _RIGHT_DETECTOR_RAYCAST_DIRECTION = Vector2.LEFT
const _LEFT_DETECTOR_RAYCAST_DIRECTION = Vector2.RIGHT
const _DETECTOR_RAYCAST_LENGTH = 8.0
const _RADIUS_PADDING = 0.2

func _ready() -> void:
	_ground_detector_l.enabled = false
	_ground_detector_r.enabled = false
	_shapecast_radius = _ground_detector_l.shape.radius + _RADIUS_PADDING


func set_active(a: bool) -> void:
	active = a


func _on_player_move_change(move_input: Vector2) -> void:

	var x = move_input.x

	if x == 0:
		_ground_detector_l.enabled = false
		_ground_detector_r.enabled = false
		_active_shapecast = null
	elif x > 0:
		_ground_detector_l.enabled = false
		_ground_detector_r.enabled = true
		_active_shapecast = _ground_detector_r
	elif x < 0:
		_ground_detector_l.enabled = true
		_ground_detector_r.enabled = false
		_active_shapecast = _ground_detector_l

	if _active_shapecast and x != 0:
		_active_shapecast.force_shapecast_update()


func _physics_process(delta: float) -> void:

	if not active:
		return

	if not _active_shapecast:
		return

	# If the area is clear the player can climb to it
	if not _is_shape_cast_empty(_active_shapecast):
		return

	var raycast_direction := Vector2.ZERO

	if _active_shapecast == _ground_detector_l:
		raycast_direction = _LEFT_DETECTOR_RAYCAST_DIRECTION.rotated(_player.rotation) * _DETECTOR_RAYCAST_LENGTH
	elif _active_shapecast == _ground_detector_r:
		raycast_direction = _RIGHT_DETECTOR_RAYCAST_DIRECTION.rotated(_player.rotation) * _DETECTOR_RAYCAST_LENGTH

	var ray_query = PhysicsRayQueryParameters2D.new()
	ray_query.from = _active_shapecast.global_position
	ray_query.to = _active_shapecast.global_position + raycast_direction
	ray_query.collision_mask = _active_shapecast.collision_mask

	var ray_result = _raycaster.intersect_ray(ray_query)
	var ray_intersection = ray_result['position']
	var climb_position = _active_shapecast.global_position
	var shapecast_distance = climb_position.distance_to(ray_intersection)

	if shapecast_distance > _shapecast_radius:
		var vector_to_climb_position = (ray_intersection - climb_position).normalized()
		var distance_to_climb_position = shapecast_distance - _shapecast_radius
		climb_position += vector_to_climb_position * distance_to_climb_position
	
	climbed_around_ledge.emit(climb_position)
	climb_started.emit()
	active = false


func _is_shape_cast_empty(shapecast: ShapeCast2D) -> bool:
	var collisions = shapecast.get_collision_count()
	return collisions == 0
