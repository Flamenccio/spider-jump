extends Node

@export var _player: Node2D
@export var dust_scene: PackedScene

func spawn_dust(normal: Vector2) -> void:
	var angle_rad = (Vector2.UP).angle_to(normal)
	TheGlobalSpawner.instantiate_scene(dust_scene, _player.global_position, angle_rad)
	print('asdf')

