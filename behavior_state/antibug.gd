extends BehaviorState

@export var _animator: SpriteTree

func enter_state() -> void:
	# Workaround to allow normal player control
	_animator.switch_sprite_branch('anti')
	set_property('powerup', 'none')
