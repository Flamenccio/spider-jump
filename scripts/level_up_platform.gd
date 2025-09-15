extends StaticBody2D

signal platform_triggered()

const _LEVEL_UP_STAMINA_RESTORE = 1.0 / 3.0

func _on_player_entered() -> void:
	PlayerStatsInterface.change_stat.emit(PlayerStatsInterface.STATS_STAMINA, _LEVEL_UP_STAMINA_RESTORE)
	platform_triggered.emit()
	GlobalFlashParticleSpawner.spawn_particle("player_level_up_text", global_position, 0.0)


func _on_player_sensor_body_entered(body:Node2D) -> void:
	body.call("on_level_up_platform_reached")
