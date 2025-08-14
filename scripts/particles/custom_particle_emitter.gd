extends Node

signal spawn_particle(particle: String, position: Vector2, rotation: float)

@export var _player: Node2D

var _jumped: bool = false

# Called when player lands
func spawn_dust(normal: Vector2) -> void:
	"""
	Don't make another particle if the player hasn't jumped yet.
	This is because the player 'lands' when they come into contact
	With another ground collider, which can also be two colliders
	from different levels next to each other and parallel.
	"""
	if not _jumped: return
	_jumped = false
	var angle_rad = (Vector2.UP).angle_to(normal)
	spawn_particle.emit('land_dust', _player.global_position, angle_rad)


# Called when player jumps
func spawn_jump_dust() -> void:
	_jumped = true
	spawn_particle.emit('jump_dust', _player.global_position, _player.rotation)


func spawn_hopperpop_jump_dust() -> void:
	_jumped = true
	spawn_particle.emit('hopperpop_jump_dust', _player.global_position, _player.rotation)


func spawn_player_hit() -> void:
	#TheGlobalSpawner.instantiate_scene(player_hit_scene, _player.global_position, 0)
	spawn_particle.emit('player_hit', _player.global_position, 0.0)
