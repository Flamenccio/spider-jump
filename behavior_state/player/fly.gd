extends BehaviorState

const _INPUT_CURVE_CONSTANT = 1.4

@export var _player: CharacterBody2D
@export var _fly_acceleration: float
@export var _max_speed: float

var _pull_input: Vector2 = Vector2.ZERO

func _on_pull_input_update(pull: Vector2) -> void:
	if not state_active:
		return
	_pull_input = pull


func update_state(delta: float) -> void:
	var fly_acceleration_constant = _fly_acceleration * delta
	var curved_input = Vector2(
		signf(_pull_input.x) * pow(absf(_pull_input.x), _INPUT_CURVE_CONSTANT),
		signf(_pull_input.y) * pow(absf(_pull_input.y), _INPUT_CURVE_CONSTANT)
	)
	var acceleration = curved_input * fly_acceleration_constant
	var new_velocity = _player.velocity + acceleration

	# Clamp speed, if necessary
	var new_speed = minf(new_velocity.length(), _max_speed)
	var normalized = new_velocity.normalized()
	_player.velocity = normalized * new_speed


func _on_pull_input_release() -> void:
	if not state_active:
		return
	set_param('flying', false)
