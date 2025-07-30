extends Node

signal climbed_around_ledge(climb_to: Vector2)
signal climb_started()

@export var _ground_detector_l: ShapeCast2D
@export var _ground_detector_r: ShapeCast2D
var _active_shapecast: ShapeCast2D
var active: bool = false

func _ready() -> void:
	_ground_detector_l.enabled = false
	_ground_detector_r.enabled = false


func set_active(a: bool) -> void:
	active = a


func _on_player_move_change(move_input: Vector2) -> void:
	var x = move_input.x
	if x == 0:
		_ground_detector_l.enabled = false
		_ground_detector_r.enabled = false
		_active_shapecast = null
		#active = false
	elif x > 0:
		_ground_detector_l.enabled = false
		_ground_detector_r.enabled = true
		_active_shapecast = _ground_detector_r
		#active = true
	elif x < 0:
		_ground_detector_l.enabled = true
		_ground_detector_r.enabled = false
		_active_shapecast = _ground_detector_l
		#active = true


func _physics_process(delta: float) -> void:
	if not active:
		return
	if not _active_shapecast:
		return
	# If the area is clear the player can climb to it
	if not _is_shape_cast_empty(_active_shapecast):
		return
	var shapecast_position = _active_shapecast.global_position
	climbed_around_ledge.emit(shapecast_position)
	climb_started.emit()
	active = false


func _is_shape_cast_empty(shapecast: ShapeCast2D) -> bool:
	var collisions = shapecast.get_collision_count()
	return collisions == 0

