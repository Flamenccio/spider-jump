class_name SpriteParticleEmitter
extends Node

@export var _particles: Array[SpriteParticle]

func spawn_particle(particle: String, position: Vector2, rotation: float = 0.0) -> void:
	var index = _particles.find_custom(func(s: SpriteParticle): return s.particle_name == particle)
	if index == -1:
		printerr('sprite particle emitter: no particle with name "{0}"'.format({'0': particle}))
		return
	_particles[index].spawn_particle(position, rotation)

