@tool
class_name ObjectSwitch
## Chooses some number of objects to keep between `min_objects` and `max_objects`
extends LevelObject

@export var min_objects: int
@export var max_objects: int
@export var objects: Array[SavedLevelObject]

## Chooses some of the objects to spawn, instantiates them, and returns the chosen instances
func choose_objects() -> Array[Node]:

	var amount_to_spawn: int = 0

	if min_objects > max_objects:
		amount_to_spawn = min_objects
	else:
		amount_to_spawn = randi_range(min_objects, max_objects)

	# Choose amount_to_spawn from objects
	# if amount_to_spawn is larger than size of objects, choose all
	var objects_to_spawn: Array[SavedLevelObject]
	if amount_to_spawn > objects.size():
		objects_to_spawn = objects
	else:
		var left = objects
		for i in range(amount_to_spawn):
			var o = left.pick_random()
			objects_to_spawn.append(o)
			left.erase(o)

	var chosen_objects: Array[Node]
	# Spawn objects
	for obj: SavedLevelObject in objects_to_spawn:
		var instance = obj.instantiate()
		chosen_objects.append(instance)

	return chosen_objects


## Saves children as `SavedLevelObject` and places them into `objects`.
func save_children() -> void:
	objects.clear()
	var children = get_children()
	for child: Node in children:
		if child is not LevelObject:
			continue
		var level_object = child as LevelObject
		var saved_object = SavedLevelObject.new()
		saved_object.save(level_object)
		objects.append(saved_object)


func get_local_properties() -> Dictionary:
	save_children()
	return {
		'objects': objects,
		'min_objects': min_objects,
		'max_objects': max_objects
	}


func rehydrate(instance: Node2D) -> void:
	if not Engine.is_editor_hint():
		return
	for obj in objects:
		instance.add_child(obj.instantiate())

