class_name ResourceBatchLoader

enum ResourceType {
	## Uses the `.res` file extension
	GENERIC,
	## Uses the `.scn` file extension
	SCENE,
	## Uses the `.tres` file extension
	TEXT_GENERIC,
	## Uses the `.tscn` file extension
	TEXT_SCENE,
}

const GENERIC_FILE_EXTENSION = ".res"
const SCENE_FILE_EXTENSION = ".scn"
const TEXT_GENERIC_FILE_EXTENSION = ".tres"
const TEXT_SCENE_FILE_EXTENSION = ".tscn"

## Resource type to load when searching paths
var resource_type : ResourceType:
	get:
		return _resource_type
	set(value):
		_resource_type = value
		var regex = ".*\\" + _get_file_extension()
		_file_extension_regex.compile(regex)

var _resource_type := ResourceType.GENERIC
var _file_extension_regex := RegEx.new()
var _file_extension_dictionary := {
	ResourceType.GENERIC: GENERIC_FILE_EXTENSION,
	ResourceType.SCENE: SCENE_FILE_EXTENSION,
	ResourceType.TEXT_GENERIC: TEXT_GENERIC_FILE_EXTENSION,
	ResourceType.TEXT_SCENE: TEXT_SCENE_FILE_EXTENSION,
}


## Returns all resource whose type is specified
## by `resource_type` found in `path`.
## If `recursive` is `true`, also loads resources from all sub-directories.
func fetch_resources_from_path(path: String, recursive: bool = true) -> Array[Resource]:

	var dir = DirAccess.open(path)

	if not dir:
		push_error('resource batch loader: invalid path "{0}"'.format({"0": path}))
		return []


	dir.list_dir_begin()
	var current_file = dir.get_next()
	var loaded_resources: Array[Resource]

	while current_file != "":
		var full_path = '{0}/{1}'.format({'0': path, '1': current_file})
		if dir.current_is_dir() and recursive:
			loaded_resources.append_array(fetch_resources_from_path(full_path, recursive))
		elif _file_extension_regex.search(current_file):
			var loaded := ResourceLoader.load(full_path)
			loaded_resources.append(loaded)
		current_file = dir.get_next()

	return loaded_resources


func fetch_resources_from_multiple_paths(paths: Array[String], recursive: bool = true) -> Array[Resource]:

	# If looking recursively, searching subdirectories may result
	# in duplicate loaded resources, so remove subdirectories
	if recursive:
		paths = _remove_subdirectories(paths)

	var loaded_resources: Array[Resource]

	# Recursively load resources
	for path in paths:
		loaded_resources.append_array(fetch_resources_from_path(path, true))

	return loaded_resources


func _remove_subdirectories(paths: Array[String]) -> Array[String]:

	paths.sort()
	var parent_paths: Array[String]
	var current_parent_path: String = paths[0]

	for i in range(paths.size()):
		var current_path = paths[i]
		if current_path == current_parent_path:
			continue
		if not current_path.begins_with(current_parent_path):
			current_parent_path = current_path
			parent_paths.append(current_path)

	return parent_paths


func _get_file_extension() -> String:
	return _file_extension_dictionary[resource_type]

