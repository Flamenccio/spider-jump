extends Node

@export var _game_manager: Node
@export var _decorations: Array[LevelDecoration]
var height: float = 0.0


func _on_level_spawned(level: Node2D) -> void:
	_decorate_level(level)


func _on_game_height_updated(height: float) -> void:
	self.height = height


func _decorate_level(level_body: Node2D) -> void:
	_scan_elevation(level_body)


func _scan_elevation(level: Node2D) -> void:
	var bottom = level.global_position.y
	var top = height
	var next_level_up_elevation = -1 * _game_manager.get_next_level_up_score(GameConstants.difficulty) * GameConstants.PIXELS_PER_POINT

	# Spawn a level up platform
	if next_level_up_elevation < bottom and next_level_up_elevation >= top:
		var plat = _get_level_decoration('level_up_platform')
		var spawn_position = Vector2(0.0, next_level_up_elevation)
		var instance = plat.instantiate_decoration(spawn_position, 0.0)
		level.add_child(instance)
		instance.global_position = spawn_position


func _get_level_decoration(decoration: String) -> LevelDecoration:
	var index = _decorations.find_custom(func(d: LevelDecoration): return d.decoration_name == decoration)
	if index < 0:
		printerr('level_decorator: no decoration with name "{0}"'.format({'0': decoration}))
		return null
	return _decorations[index]
