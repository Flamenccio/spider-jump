extends Node
## Flips the player's sprite depending on velocity

var _flipped = false

@export var _sprite_tree: SpriteTree
@export var _player: CharacterBody2D

func _physics_process(delta: float) -> void:

	var rotation = _player.rotation
	var velocity = _player.velocity
	var counter_rotated_velocity = velocity.rotated(-rotation)

	if counter_rotated_velocity.x < 0 and _flipped:
		_flipped = false
		_sprite_tree.flip_horizontal(false)
	elif counter_rotated_velocity.x > 0 and not _flipped:
		_flipped = true
		_sprite_tree.flip_horizontal(true)
