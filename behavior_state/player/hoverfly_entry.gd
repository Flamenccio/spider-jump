extends BehaviorState

@export var _player: CharacterBody2D

func enter_state() -> void:
	# Reduce velocity on collect
	_player.velocity /= 3.0
