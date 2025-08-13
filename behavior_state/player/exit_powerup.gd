extends BehaviorState

@export var _animator: SpriteTree

func enter_state() -> void:
	_animator.switch_sprite_branch('normal')
