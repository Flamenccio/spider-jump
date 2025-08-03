@tool
extends Node2D

@export_group('Save settings')
@export var _save_level_name: String
@export var _save_path: String
@export_tool_button('Save') var _save_button: Callable = _save

@export_group('Load settings')
@export var _load_level_name: String
@export var _load_path: String
@export_tool_button('Load') var _load_button: Callable = _load

const _SAVE_EXTENSION = '.res'

func _save() -> void:

	if _save_level_name == '' or _save_level_name == null:
		printerr('level builder: invalid level name!')
		return
	
	if _save_path == '' or _save_path == null:
		printerr('level builder: invalid save path!')
		return

	print('level builder: saving...')
	var saved_level = SavedLevel.new()
	saved_level.save_level(self as Node2D)
	var result = ResourceSaver.save(saved_level, _save_path + _save_level_name + _SAVE_EXTENSION)

	if result != OK:
		printerr('level builder: something went wrong')
	else:
		print('level builder: successfully saved level at "{0}"'.format({'0': _save_path + _save_level_name + _SAVE_EXTENSION}))


func _load() -> void:

	if not Engine.is_editor_hint():
		return

	if _load_level_name == null or _load_level_name == '':
		printerr('level builder: invalid level name')
		return

	if _load_path == null or _load_path == '':
		printerr('level builder: invalid load path')
		return

	var loaded_scene := ResourceLoader.load(_load_path + _load_level_name + _SAVE_EXTENSION) as SavedLevel

	if loaded_scene == null:
		printerr('level builder: something went wrong with loading level "{0}"'.format({'0': _load_level_name}))
		return

	for child in get_children():
		child.free()
	var level = loaded_scene.instantiate()
	var editor_root = get_tree().edited_scene_root
	for level_child in level.get_children():
		level_child.reparent(self)
	_set_owner_recursive(editor_root, self)
	level.queue_free()
	print('level builder: successfully loaded scene "{0}"'.format({'0': loaded_scene.saved_name}))


func _set_owner_recursive(new_owner: Node, target: Node) -> void:
	if target.owner == null and target != new_owner:
		target.owner = new_owner
	var target_children = target.get_children()
	if target_children.size() == 0:
		return
	for child in target_children:
		_set_owner_recursive(new_owner, child)

