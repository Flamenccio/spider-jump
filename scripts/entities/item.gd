class_name Item
extends Node2D

@export var _item_id: String
var item_id: String:
	get:
		return _item_id
	set(value):
		return

func remove_powerup() -> void:
	print('removed!')
	TheGlobalSpawner.instantiate_scene(load("res://scenes/level_objects/yummy_fly.tscn"), global_position, 0.0)
	queue_free()
