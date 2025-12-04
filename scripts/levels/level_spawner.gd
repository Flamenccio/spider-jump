extends Node2D

signal new_level_spawned(total_height: float)
signal new_level_body_spawned(level_body: Node2D)

@export var _level_path: String = ''
@export var _initial_level: SavedLevel
@export var _spawn_trigger: Node
var _res_regex = RegEx.new()
var _loaded_levels: Array[SavedLevel]

## Levels availble to spawn at the current difficulty level
var _available_levels: Array[SavedLevel]

## How high the tower is
var _game_height: int = 0

# Queue of active levels
var _active_levels_queue: Array[Node]

# Queue of the level types spawned. Corresponds to `_active_levels_queue`.
var _level_type_history: Array[String]

# 7th oldest level will be destroyed
const _MAX_ACTIVE_LEVELS = 4

# If a level type appears this many times in the level history, it cannot be the next level
const _MAX_DUPLICATE_LEVEL_TYPES = 2

func spawn_new_level(excluding: Array[String] = []) -> void:
	var random

	if excluding.size() > 0:
		var filtered_levels = _available_levels.duplicate()
		for excluded in excluding:
			var erase_index = filtered_levels.find_custom(func(l: SavedLevel): return l.saved_name == excluded)
			filtered_levels.remove_at(erase_index)
		random = filtered_levels.pick_random() as SavedLevel

	random = _available_levels.pick_random() as SavedLevel
	var active_duplicates := _level_type_history.count(random.saved_name)

	if active_duplicates == 0:
		_spawn_level(random)
		return
	
	# Lower chance of spawning
	var r = randf_range(0.0, 1.0)
	var threshold = (float(active_duplicates) / float(_MAX_DUPLICATE_LEVEL_TYPES))
	if r > threshold:
		_spawn_level(random)
		return

	# Spawn another level type!
	excluding.append(random.saved_name)
	spawn_new_level(excluding)


func _ready() -> void:

	if _level_path == '' or _level_path == null:
		printerr('level spawner: invalid level path!')
		return

	if _initial_level == null:
		print('level spawner: WARNING! initial level is null!')

	var loader = ResourceBatchLoader.new()
	loader.resource_type = ResourceBatchLoader.ResourceType.GENERIC
	var loaded_resources = loader.fetch_resources_from_path(_level_path)
	loaded_resources = loaded_resources.filter(func(r: Resource): return r is SavedLevel)

	for resource in loaded_resources:
		_loaded_levels.append(resource as SavedLevel)

	# Remove initial level from loaded levels
	_loaded_levels.erase(_initial_level)
	_loaded_levels = _loaded_levels.filter(func(l: SavedLevel): return l != null)

	# Remove levels with a minimum difficulty below 0
	_loaded_levels = _loaded_levels.filter(func(l: SavedLevel): return l.minimum_level >= 0)

	_on_level_up(0)
	
	# Spawn two levels at first
	_spawn_level(_initial_level)
	_spawn_trigger.call('travel_to_next_elevation')
	spawn_new_level()


func _spawn_level(level: SavedLevel) -> void:
	var new_level_height = level.level_height
	var instance = level.instantiate()
	call_deferred('add_child', instance)
	instance.global_position = Vector2(0, _game_height)
	_game_height -= new_level_height
	new_level_spawned.emit(_game_height)
	new_level_body_spawned.emit(instance as Node2D)

	# Track new level and destroy old one
	_active_levels_queue.push_back(instance)
	_level_type_history.push_back(level.saved_name)
	if _active_levels_queue.size() >= _MAX_ACTIVE_LEVELS:
		var old = _active_levels_queue.pop_front() as Node
		_level_type_history.pop_front()
		old.queue_free()


# Filter out levels that do not meet minimum difficulty (level) requirement
func _on_level_up(new_level: int) -> void:
	_available_levels = _loaded_levels.filter(func(l: SavedLevel): return l.minimum_level <= new_level)
