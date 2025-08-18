@tool
class_name SavedItem
extends SavedNode

@export var load_path: String
@export var local_position: Vector2

func save_item(item: Node2D) -> void:
	load_path = item.get_script().get_path()
	local_position = item.position
	saved_name = item.name


func instantiate() -> Node2D:
	var instance := load(load_path).instantiate() as Node2D
	instance.position = local_position

	if saved_name == '':
		instance.name = 'Item'
	else:
		instance.name = saved_name

	return instance
