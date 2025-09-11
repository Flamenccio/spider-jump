@tool
class_name GenericItem
extends Resource

const DEFAULT_SPRITE_ORDER = 10

@export var item_id: String
@export var sprites: Array[Texture2D]
@export var sprite_frames: Array[SpriteFrames]
@export var collision_shape: Shape2D
@export var is_powerup: bool = false

## Instantiates and returns an item with its saved properties
func instantiate_item() -> Node2D:

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

	if is_powerup:
		instance.add_to_group("powerup")

	return instance


## Copies `item`s properties. You can overwrite properties afterward
## if necessary.
func save_item(item: StaticBody2D) -> void:

	# Save node name as id
	item_id = item.name.to_snake_case()

	# Search through the children
	var children = item.get_children()
	for child in children:
		if child is Sprite2D:
			sprites.append((child as Sprite2D).texture)
		elif child is AnimatedSprite2D:
			sprite_frames.append((child as AnimatedSprite2D).sprite_frames)
		elif child is CollisionShape2D:
			collision_shape = (child as CollisionShape2D).shape
