@tool
class_name SavedTilemapCollider
extends SavedNode

@export var _colliders: Array[SavedCollisionShape]
@export var collision_layer: int
@export var collision_mask: int
@export var saved_position: Vector2

func instantiate() -> Node2D:

	var instance = StaticBody2D.new()
	instance.name = saved_name
	instance.collision_layer = collision_layer
	instance.collision_mask = collision_mask
	instance.position = saved_position

	for collider in _colliders:
		instance.add_child(collider.instantiate())

	return instance


func save_collider(collider: StaticBody2D) -> void:

	# Save shapes
	var children = collider.get_children()
	_colliders.clear()
	
	for child in children:
		if child is CollisionShape2D:
			var saved_shape = SavedCollisionShape.new()
			saved_shape.save_collision_shape(child)
			_colliders.append(saved_shape)

	# Save local stuff
	saved_name = collider.name
	collision_layer = collider.collision_layer
	collision_mask = collider.collision_mask
	saved_position = collider.position
