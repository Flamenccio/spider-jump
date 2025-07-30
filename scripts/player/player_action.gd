class_name PlayerAction
extends Node

@export var _player_rb: RigidBody2D
@export var action_active: bool = false

func set_active() -> void:
	action_active = true


func set_inactive() -> void:
	action_active = false