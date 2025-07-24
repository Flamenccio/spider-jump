extends Area2D

signal player_fell()
@export var vfx: PackedScene

func _on_body_entered(body: Node2D) -> void:
	var pos = Vector2(body.global_position.x, global_position.y)
	TheGlobalSpawner.instantiate_scene(vfx, pos, 0.0)
	player_fell.emit()
