class_name SavedCollisionShape
extends SavedNode

@export var shape: Shape2D
@export var position: Vector2

func instantiate() -> Node2D:
	var instance = CollisionShape2D.new()
	instance.name = saved_name
	instance.shape = shape
	instance.global_position = position
	return instance


func save_collision_shape(collision: CollisionShape2D) -> void:
	saved_name = collision.name
	shape = collision.shape
	position = collision.global_position