@tool
extends Node2D

@export_group('Save settings')
@export var _level_name: String
@export var _save_path: String
@export_tool_button('Save') var _save_button: Callable = _save

const _SAVE_EXTENSION = '.res'

func _save() -> void:

	if _level_name == '' or _level_name == null:
		printerr('level builder: invalid level name!')
		return
	
	if _save_path == '' or _save_path == null:
		printerr('level builder: invalid save path!')
		return

	print('level builder: saving...')
	var saved_level = SavedLevel.new()
	saved_level.save_level(self as Node2D)
	var result = ResourceSaver.save(saved_level, _save_path + _level_name + _SAVE_EXTENSION)

	if result != OK:
		printerr('level builder: something went wrong')
	else:
		print('level builder: successfully saved level at "{0}"'.format({'0': _save_path + _level_name + _SAVE_EXTENSION}))