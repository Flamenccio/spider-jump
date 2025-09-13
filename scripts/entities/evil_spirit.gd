extends StaticBody2D

signal evil_spirit_activated()

const _FOLLOW_DELAY_SECONDS = 1.0
# Physics ticks per second * follow delay in seconds
const _MAX_TRACKED_POSITIONS = roundi(60 * _FOLLOW_DELAY_SECONDS)

# Minimum distance from the event origin
const _MIN_ACTIVATION_DISTANCE = 100

var target: Node2D
var _tracked_positions: Array[Vector2]
var _event_origin: Vector2
var _event_origin_set: bool = false
var _active: bool = false


func _physics_process(delta: float) -> void:
	_wait_target_distance()
	_track_target()


## Set the event origin to `global_origin`. Frozen once set.
## If the player goes far away enough from the event origin,
## the evil spirit is summoned.
func set_event_origin(global_origin: Vector2) -> void:
	if _event_origin_set:
		return
	_event_origin = global_origin
	_event_origin_set = true


func _track_target() -> void:

	if target == null:
		return

	# Enqueue new position
	_tracked_positions.push_back(target.global_position)

	# Move to oldest position
	if _active:
		var go_to = _tracked_positions.pop_front()
		global_position = go_to

	# Remove oldest position if stored amount is larger than
	# _MAX_TRACKED_POSITIONS
	if _tracked_positions.size() > _MAX_TRACKED_POSITIONS:
		_tracked_positions.pop_front()


# Wait for the target to create some distance from event origin
func _wait_target_distance() -> void:
	if _active:
		return
	if target == null:
		return
	if not _event_origin_set:
		return
	if target.global_position.distance_to(_event_origin) > _MIN_ACTIVATION_DISTANCE:
		_active = true
		evil_spirit_activated.emit()