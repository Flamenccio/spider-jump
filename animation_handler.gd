extends Node

@export var _sprite: AnimatedSprite2D

func on_player_land() -> void:
	_sprite.play('idle')


func on_player_jump() -> void:
	_sprite.play('jump')


func on_player_jump_ready() -> void:
	_sprite.play('charge')
