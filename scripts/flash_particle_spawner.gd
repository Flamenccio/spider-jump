class_name FlashParticleSpawner
extends Node

const PARTICLE_PATH = "res://resources/flash_particles"

var _flash_particles := { }

func _ready() -> void:
	
	var loader = ResourceBatchLoader.new()
	loader.resource_type = ResourceBatchLoader.ResourceType.TEXT_GENERIC
	var particles = loader.fetch_resources_from_path(PARTICLE_PATH)
	particles.filter(func(r: Resource): return r is SavedFlashParticle)
	
	for particle in particles:
		_flash_particles[particle.particle_name] = particle


func spawn_particle(particle_id: String, global_position: Vector2, rotation: float) -> void:
	
	if not _flash_particles.keys().has(particle_id):
		return
	
	var saved_particle = _flash_particles[particle_id]
	saved_particle.instantiate_particle(global_position, rotation)
