class_name GlobalSpawner
extends Node2D

func _ready() -> void:
	GameEventBus.game_restarted.connect(_on_game_restarted)


func instantiate_scene(scene: PackedScene, spawn_position: Vector2, angle_rad: float) -> void:
	var instance = scene.instantiate()
	if instance is Node2D:
		var node2d = instance as Node2D
		node2d.global_position = spawn_position
		node2d.rotation = angle_rad
		add_child(node2d)
	else: add_child(instance)


func inherit_node(node: Node) -> void:
	add_child(node)


func _on_game_restarted() -> void:
	for c in get_children():
		c.queue_free()
