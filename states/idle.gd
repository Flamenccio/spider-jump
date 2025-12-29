extends BehaviorState

signal player_entered_idle()

var _pull_pressed := false

@export var _animator: SpriteTree
@export var _player: CharacterBody2D

@onready var _action_buffer := %ActionBuffer

func enter_state() -> void:

	_player.velocity = Vector2.ZERO
	set_param('jump', false)
	_animator.play_branch_animation('idle')
	player_entered_idle.emit()

	if GameConstants.current_powerup == ItemIds.BLINKFLY_POWERUP:
		GameConstants.current_gravity = GameConstants.DEFAULT_GRAVITY

	# Check action buffer
	if _pull_pressed:
		set_param("buffered_jump", Vector2.ZERO)
		return

	var action_idx = _action_buffer.get_buffered_action_index(_action_buffer.ActionType.JUMP)
	if action_idx < 0:
		set_param("buffered_jump", Vector2.ZERO)
		return

	var action = _action_buffer.pop_buffered_action(action_idx)

	set_param("buffered_jump", action.action_value)
	set_param("aim", true)


func _on_pull_pressed() -> void:
	_pull_pressed = true


func _on_pull_released() -> void:
	_pull_pressed = false

