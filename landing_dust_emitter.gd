extends Node

@export var _player: Node2D
@export var dust_scene: PackedScene
@export var jump_dust_scene: PackedScene

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
	TheGlobalSpawner.instantiate_scene(dust_scene, _player.global_position, angle_rad)


# Called when player jumps
func spawn_jump_dust() -> void:
	_jumped = true
	TheGlobalSpawner.instantiate_scene(jump_dust_scene, _player.global_position, _player.rotation)
