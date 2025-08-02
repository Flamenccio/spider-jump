extends StaticBody2D

@export var _particle_emitter: SpriteParticleEmitter
signal platform_triggered()

func _on_player_entered() -> void:
	_particle_emitter.spawn_particle('level_up_text', global_position)
	platform_triggered.emit()
