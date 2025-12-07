extends BehaviorState

signal player_entered_idle()

@export var _animator: SpriteTree
@export var _player: CharacterBody2D

func enter_state() -> void:

	_player.velocity = Vector2.ZERO
	set_param('jump', false)
	_animator.play_branch_animation('idle')
	player_entered_idle.emit()

	if GameConstants.current_powerup == ItemIds.BLINKFLY_POWERUP:
		GameConstants.current_gravity = GameConstants.DEFAULT_GRAVITY


