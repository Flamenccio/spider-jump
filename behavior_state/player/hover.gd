extends BehaviorState

@export var _player: CharacterBody2D
@export_range(0.0, 100.0) var _decceleration: float = 1.0

const _ZERO_VELOCITY_THRESHOLD = 0.001
const _TARGET_VELOCITY = Vector2.ZERO

func tick_state(delta: float) -> void:

	var velocity = _player.velocity

	if velocity.length() <= _ZERO_VELOCITY_THRESHOLD:
		_player.velocity = Vector2.ZERO
		return

	var decceleration_constant = _decceleration * -1 * delta
	_player.velocity += Vector2(decceleration_constant * velocity.x, decceleration_constant * velocity.y)
	_player.move_and_slide()


func _on_pull_input_press() -> void:

	if not state_active:
		return

	set_property('Powerup/Hoverfly/flying', true)
