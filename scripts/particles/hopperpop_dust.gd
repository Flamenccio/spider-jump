extends CPUParticles2D

@export var _player: CharacterBody2D

func _process(delta: float) -> void:
	if not emitting:
		return
	direction = _player.get_real_velocity().rotated(-_player.rotation)
