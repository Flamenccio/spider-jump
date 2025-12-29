@tool
class_name StaticItemData
extends ItemData
## Item data for items that have no special behavior.

@export var sprites: Array[Texture2D]
@export var sprite_frames: Array[SpriteFrames]
@export var collision_shape: Shape2D

func _instantiate_item() -> Node2D:

	var instance = Item.new()

	for sprite in sprites:
		var sprite_instance = Sprite2D.new()
		sprite_instance.texture = sprite
		sprite_instance.z_index = DEFAULT_SPRITE_ORDER
		instance.add_child(sprite_instance)

	for sprite_frame in sprite_frames:
		var animated_sprite_instance = AnimatedSprite2D.new()
		animated_sprite_instance.sprite_frames = sprite_frame
		animated_sprite_instance.z_index = DEFAULT_SPRITE_ORDER
		instance.add_child(animated_sprite_instance)
	
	var collider_instance = CollisionShape2D.new()
	collider_instance.shape = collision_shape
	instance.add_child(collider_instance)
	instance.item_id = item_id
	instance.name = item_id.to_pascal_case()
	instance.collision_layer = ITEM_LAYER

	if is_item_powerup():
		instance.add_to_group("powerup", true)

	return instance