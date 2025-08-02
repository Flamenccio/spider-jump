extends StaticBody2D

signal platform_triggered()

func _on_player_entered() -> void:
	platform_triggered.emit()
