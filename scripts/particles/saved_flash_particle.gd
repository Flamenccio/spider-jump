class_name SavedFlashParticle
extends Resource
## One shot particle based on animated sprites

@export var particle_name: String
@export var frames: SpriteFrames
@export var offset: Vector2
@export var scale: Vector2 = Vector2(1.0, 1.0)
@export var shader: ShaderMaterial
@export var z_index: int = 10

func instantiate_particle(global_position: Vector2, rotation: float = 0.0) -> void:
	var instance := FlashParticle.new()
	instance.sprite_frames = frames
	call_deferred("_add_particle", instance, global_position, rotation)


func _add_particle(particle: FlashParticle, global_position: Vector2, rotation: float) -> void:
	TheGlobalSpawner.add_child(particle)
	particle.global_position = global_position
	particle.rotation = rotation
	particle.offset = offset
	particle.z_index = z_index
	particle.scale = scale
	particle.material = shader
	var animations = frames.get_animation_names()
	particle.play(animations[0])
