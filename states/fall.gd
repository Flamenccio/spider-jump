extends BehaviorState

@export var _animator: AnimatedSprite2D

func enter_state() -> void:
	_animator.play('fall')
