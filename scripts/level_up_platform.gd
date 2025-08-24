extends StaticBody2D

@export var _particle_emitter: SpriteParticleEmitter
signal platform_triggered()

const _LEVEL_UP_STAMINA_RESTORE = 1.0 / 3.0

func _on_player_entered() -> void:
	_particle_emitter.spawn_particle('level_up_text', global_position)
	PlayerStatsInterface.change_stat.emit(PlayerStatsInterface.STATS_STAMINA, _LEVEL_UP_STAMINA_RESTORE)
	platform_triggered.emit()
