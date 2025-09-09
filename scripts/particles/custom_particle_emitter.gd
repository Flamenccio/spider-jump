extends Node

var _jumped: bool = false
var _particle_spawner := GlobalFlashParticleSpawner

@export var _player: Node2D

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
	_particle_spawner.spawn_particle("player_land_dust", _player.global_position, angle_rad)


# Called when player jumps
func spawn_jump_dust() -> void:
	_jumped = true
	_particle_spawner.spawn_particle("player_jump_dust", _player.global_position, _player.rotation)

# Called when player jumps under the hopperpop powerup
func spawn_hopperpop_jump_dust() -> void:
	_jumped = true
	_particle_spawner.spawn_particle("player_hopperpop_jump_dust", _player.global_position, _player.rotation)


func spawn_bubblebee_jump_dust() -> void:
	_jumped = true
	_particle_spawner.spawn_particle("player_bubblebee_jump_dust", _player.global_position, _player.rotation)


func spawn_player_hit() -> void:
	_particle_spawner.spawn_particle("player_hit", _player.global_position, 0)


func spawn_powerup_flash() -> void:
	_particle_spawner.spawn_particle("player_powerup_gain", _player.global_position, 0)
	_particle_spawner.spawn_particle("player_powerup_gain", _player.global_position, PI / 2.0)
