extends Area2D

signal player_fell()

func _on_body_entered(body: Node2D) -> void:
	player_fell.emit()

