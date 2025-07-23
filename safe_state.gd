extends Node
"""
Saves the last place the player was standing
"""

@export var _player: CharacterBody2D
var _position: Vector2
var _rotation: float

func _save_state() -> void:
	var rounded_position = Vector2(roundf(_player.global_position.x), roundf(_player.global_position.y))
	_position = rounded_position
	_rotation = _player.rotation

func restore_state() -> void:
	_player.global_position = _position
	_player.rotation = _rotation
	_player.velocity = Vector2.ZERO
