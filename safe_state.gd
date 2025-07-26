extends Node
"""
Saves the last place the player was standing
"""

@export var _player: CharacterBody2D
@export var _danger_shapecast: ShapeCastCheck
@export var _ground_shapecast: ShapeCastCheck
var _position: Vector2
var _rotation: float

const _MAX_SHAPECAST_RESULTS = 1

func _save_state() -> void:
	var rounded_position = Vector2(roundf(_player.global_position.x), roundf(_player.global_position.y))

	# Check area for danger (spikes)
	var results := _danger_shapecast.intersect_shape(Vector2.ZERO, _MAX_SHAPECAST_RESULTS, false)
	if results.size() > 0:
		print('danger!!')
		return

	_position = rounded_position
	_rotation = _player.rotation

func restore_state(soft: bool) -> void:
	if soft:
		return

	_player.global_position = _position
	_player.rotation = _rotation
	_player.velocity = Vector2.ZERO
