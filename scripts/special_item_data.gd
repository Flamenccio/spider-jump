class_name SpecialItemData
extends ItemData
## Resource for special items. These types of items have in-game behavior.

@export var item_scene: PackedScene

func _instantiate_item() -> Node2D:
	var instance = item_scene.instantiate()
	if is_item_powerup():
		instance.add_to_group("powerup")
	instance.collision_layer = ITEM_LAYER
	return instance