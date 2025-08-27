extends Node

signal player_damaged()
signal lose_powerup()

func _on_danger_entered(body: Node2D) -> void:

	# Ignore if heavy beetle
	if GameConstants.current_powerup == ItemIds.HEAVY_BEETLE_POWERUP:
		return

	# If the player has a powerup, lose the powerup
	# instead of losing health
	if GameConstants.current_powerup != ItemIds.NO_POWERUP:
		lose_powerup.emit()
		return

	player_damaged.emit()
