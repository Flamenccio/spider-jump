extends Area2D

signal player_fell()

func _on_body_entered(body: Node2D) -> void:
	var pos = Vector2(body.global_position.x, global_position.y)
	GlobalFlashParticleSpawner.spawn_particle("player_death_flash", pos, 0.0)
	GlobalSoundManager.play_sound("player/die")
	player_fell.emit()
	PlayerEventBus.player_fell.emit(pos)
