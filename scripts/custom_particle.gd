class_name SpriteParticle
extends Resource

@export var particle_name: String
@export var particle_scene: PackedScene

func spawn_particle(global_position: Vector2, rotation: float) -> void:
	TheGlobalSpawner.instantiate_scene(particle_scene, global_position, rotation)
