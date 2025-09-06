extends Node

# Events can spawn if the difficulty is at least equal to this
const MINIMUM_EVENT_LEVEL = 6
const MAXIMUM_EVENT_HISTORY = 2
const NO_EVENT = 'none'

@export var _camera: Node2D
@export var _debug_lasers_event: PackedScene
var _current_event := NO_EVENT
var _event_history: Array[String]
var _events: Dictionary = {
	'lasers': _event_lasers,
	#'sniper': _event_sniper,
	#'blockade': _event_blockade
}
var _score_update_functions: Callable

"""
TODO: Create level events, which can spawn when the difficulty level is at least
MINIMUM_EVENT_LEVEL.
- Level events cannot spawn consecutively
- The next level event must be different from the last one
- 50/50 chance of event spawning
"""

func _on_level_spawned(level: Node2D) -> void:

	if GameConstants.difficulty < MINIMUM_EVENT_LEVEL:
		return

	if _current_event != NO_EVENT:
		return

	var roll = randf()
	if roll >= 0.5:
		return

	_spawn_random_event()


func _spawn_random_event() -> void:

	var events_ids = _events.keys()
	for id in _event_history:
		events_ids.erase(id)

	if events_ids.size() == 0:
		push_warning('no events left')
		return

	var event_id = events_ids.pick_random()
	var event = _events[event_id]

	if event == null:
		push_warning('no event with id ', event_id)
		return

	_current_event = event_id
	event.call()
	_event_history.push_back(event_id)

	if _event_history.size() > MAXIMUM_EVENT_HISTORY:
		_event_history.pop_front()


func _event_lasers() -> void:
	var instance = _debug_lasers_event.instantiate()
	_score_update_functions = instance.on_score_updated
	_camera.add_child(instance)
	instance.call('start_event')


func _event_sniper() -> void:
	print('event: sniper')
	pass


func _event_blockade() -> void:
	print('event: blockade')
	pass


func _on_score_updated(score: int) -> void:
	if not _score_update_functions.is_valid():
		return
	_score_update_functions.call(score)
