extends BehaviorState

@export var _animator: SpriteTree

func enter_state() -> void:
	_animator.switch_and_play('hoverfly', 'hover')
