extends Node

# Events can spawn if the difficulty is at least equal to this
const MINIMUM_EVENT_LEVEL = 6
const MAXIMUM_EVENT_HISTORY = 1
const NO_EVENT = 'none'
# Number of levels that must spawn after an event finishes
# for another event to spawn
const EVENT_COOLDOWN = 3

@export_dir var _level_event_path: String
@export var _camera: Node2D

var _loaded_events: Dictionary
var _current_event := NO_EVENT
var _event_cooldown := 0
var _event_history: Array[String]
var _score_update_functions: Callable

func _ready() -> void:

	var loader := ResourceBatchLoader.new()
	loader.resource_type = ResourceBatchLoader.ResourceType.TEXT_GENERIC
	var loaded_resources := loader.fetch_resources_from_path(_level_event_path, false)
	loaded_resources = loaded_resources.filter(func(r: Resource): return r is NamedPackedScene)

	for resource: NamedPackedScene in loaded_resources:
		_loaded_events[resource.name] = resource.packed_scene


func _on_level_spawned(level: Node2D) -> void:

	if GameConstants.difficulty < MINIMUM_EVENT_LEVEL:
		return

	if _current_event != NO_EVENT:
		return

	if _event_cooldown > 0:
		_event_cooldown -= 1
		return

	var roll = randf()
	if roll >= 0.5:
		return

	_spawn_random_event()
	_event_cooldown = EVENT_COOLDOWN


func _spawn_random_event() -> void:

	var events_ids = _loaded_events.keys()
	for id in _event_history:
		events_ids.erase(id)

	if events_ids.size() == 0:
		push_warning('no events left')
		return

	var event_id = events_ids.pick_random()
	var event = _loaded_events[event_id] as PackedScene

	if event == null:
		push_warning('no event with id ', event_id)
		return

	_current_event = event_id
	_event_history.push_back(event_id)

	call_deferred("_add_event", event)

	if _event_history.size() > MAXIMUM_EVENT_HISTORY:
		_event_history.pop_front()


func _add_event(event: PackedScene) -> void:
	var instance = event.instantiate()
	_score_update_functions = instance.on_score_updated
	instance.event_finished.connect(_on_event_finished)
	TheGlobalSpawner.add_child(instance)
	instance.call('start_event')


func _on_score_updated(score: int) -> void:
	if not _score_update_functions.is_valid():
		return
	_score_update_functions.call(score)


func _on_event_finished() -> void:
	_current_event = NO_EVENT
