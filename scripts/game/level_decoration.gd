class_name LevelDecoration
extends Resource

@export var decoration_name: String
@export var scene: PackedScene
@export var difficulty_level: int = 0

func instantiate_decoration(position: Vector2, rotation: float) -> Node2D:
	var instance = scene.instantiate() as Node2D
	instance.global_position = position
	instance.rotation = rotation
	return instance

