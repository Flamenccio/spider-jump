extends BehaviorState

@export var _animator: AnimatedSprite2D
@export var _gravity_scale: float = 1.0
@export var _player: CharacterBody2D

signal player_entered_idle()

func enter_state() -> void:
	_player.velocity = Vector2.ZERO
	set_property('jump', false)
	_animator.play('idle')
	player_entered_idle.emit()
