extends Node2D

signal new_level_spawned(total_height: float)

@export var _level_path: String = ''
@export var _initial_level: SavedLevel
@export var _spawn_trigger: Node
var _res_regex = RegEx.new()
var _loaded_levels: Array[SavedLevel]

## How high the tower is
var _game_height: int = 0

# Queue of active levels
var _active_levels_queue: Array[Node]

# 7th oldest level will be destroyed
const _MAX_ACTIVE_LEVELS = 6


func _ready() -> void:

	if _level_path == '' or _level_path == null:
		printerr('level spawner: invalid level path!')
		return

	if _initial_level == null:
		print('level spawner: WARNING! initial level is null!')

	_res_regex.compile('.*\\.res')
	_loaded_levels = _load_levels(_level_path)

	# Remove initial level from loaded levels
	_loaded_levels.erase(_initial_level)
	
	# Spawn two levels at first
	_spawn_level(_initial_level)
	_spawn_trigger.call('travel_to_next_elevation')
	spawn_new_level()


func _load_levels(path: String) -> Array[SavedLevel]:

	var loaded_levels: Array[SavedLevel] = []
	var dir := DirAccess.open(path)
	dir.list_dir_begin()
	var current = dir.get_next()

	if not dir:
		printerr('level spawner: unable to open path "{0}"'.format({'0': path}))
		return loaded_levels

	# Searches through the directory recursively
	while current != '':
		if dir.current_is_dir():
			loaded_levels.append_array(_load_levels(current))
		elif _res_regex.search(current):
			var loaded := ResourceLoader.load(dir.get_current_dir() + current)
			if loaded is not SavedLevel:
				print('level spawner: WARNING! "{0}" is not a SavedLevel!'.format({'0': current}))
			loaded_levels.append(loaded)
		current = dir.get_next()
	
	dir.list_dir_end()
	return loaded_levels


func _spawn_level(level: SavedLevel) -> void:
	var new_level_height = level.level_height
	var instance = level.instantiate()
	call_deferred('add_child', instance)
	instance.global_position = Vector2(0, _game_height)
	_game_height -= new_level_height
	new_level_spawned.emit(_game_height)

	# Track new level and destroy old one
	_active_levels_queue.push_back(instance)
	if _active_levels_queue.size() >= _MAX_ACTIVE_LEVELS:
		var old = _active_levels_queue.pop_front() as Node
		old.queue_free()
		print('DESTROYED: ', old.get_instance_id())


func spawn_new_level():
	var random := _loaded_levels.pick_random() as SavedLevel
	#print('random level: ', random)
	_spawn_level(random)

