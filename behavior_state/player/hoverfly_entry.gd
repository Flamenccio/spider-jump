extends BehaviorState

signal entered_hoverfly()

@export var _player: CharacterBody2D

func enter_state() -> void:
	# Reduce velocity on collect
	_player.velocity /= 3.0
	entered_hoverfly.emit()
