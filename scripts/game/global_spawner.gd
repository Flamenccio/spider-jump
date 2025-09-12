class_name GlobalSpawner
extends Node2D

func instantiate_scene(scene: PackedScene, position: Vector2, angle_rad: float) -> void:
	var instance = scene.instantiate()
	if instance is Node2D:
		var node2d = instance as Node2D
		node2d.global_position = position
		node2d.rotation = angle_rad
		add_child(node2d)
	else: add_child(instance)
