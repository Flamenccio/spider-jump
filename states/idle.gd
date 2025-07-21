extends BehaviorState

@export var _animator: AnimatedSprite2D
@export var _gravity_scale: float = 1.0
@export var _player: CharacterBody2D

func enter_state() -> void:
	_player.velocity = Vector2.ZERO
	set_property('jump', false)
	_animator.play('idle')
