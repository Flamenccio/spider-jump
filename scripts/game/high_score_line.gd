extends Node2D

signal player_entered()

func _ready() -> void:

	var high_score = GameConstants.high_score
	if high_score == null or high_score == 0:
		queue_free()
		return

	global_position = Vector2(0.0, -1 * high_score * GameConstants.PIXELS_PER_POINT)


func _on_player_entered() -> void:
	GlobalFlashParticleSpawner.spawn_particle("player_high_score_text", global_position, 0.0)
	player_entered.emit()


func _on_confetti_particle_finished() -> void:
	queue_free()
