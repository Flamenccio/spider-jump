@tool
class_name SavedLevelObject
extends Resource

@export var packed_scene: PackedScene
@export var local_position: Vector2
@export var local_rotation: float
@export var local_properties: Dictionary

func instantiate() -> Node2D:
	var instance := packed_scene.instantiate() as Node2D

	for key in local_properties.keys():
		var value = local_properties[key]
		if typeof(local_properties[key]) == TYPE_ARRAY:
			var array_ref = instance.get(key) as Array
			array_ref.clear()
			array_ref.append_array(value)
		else:
			instance.set(key, value)

	instance.position = local_position
	instance.rotation = local_rotation

	if instance is LevelObject:
		(instance as LevelObject).rehydrate(instance)

	return instance


func save(object: LevelObject) -> void:
	packed_scene = load(object.packed_scene_path)
	local_position = object.position
	local_rotation = object.rotation
	local_properties = object.get_local_properties()

