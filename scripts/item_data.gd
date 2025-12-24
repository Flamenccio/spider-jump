class_name ItemData
extends Resource
## Resource of an item's data.
##
## It can be instantiated with its [code]instantiate_item[/code] function.

const DEFAULT_SPRITE_ORDER = 10
const ITEM_LAYER = 8

## Unique identifier for this item
@export var item_id: String

func instantiate_item() -> Node2D:
	return _instantiate_item()


func is_item_powerup() -> bool:
	return ItemIds.is_item_powerup(item_id)


func _instantiate_item() -> Node2D:
	return null