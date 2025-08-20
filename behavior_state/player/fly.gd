extends BehaviorState

@export var _player: CharacterBody2D
@export var _fly_acceleration: float
@export var _max_speed: float

var _pull_input: Vector2 = Vector2.ZERO

func _on_pull_input_update(pull: Vector2) -> void:
	if not state_active:
		return
	_pull_input = pull


func tick_state(delta: float) -> void:
	var fly_acceleration_constant = _fly_acceleration * delta
	var acceleration = Vector2(_pull_input.x * fly_acceleration_constant, _pull_input.y * fly_acceleration_constant)
	var new_velocity = _player.velocity + acceleration

	# Clamp speed, if necessary
	var new_speed = minf(new_velocity.length(), _max_speed)
	var normalized = new_velocity.normalized()
	_player.velocity = normalized * new_speed

	_player.move_and_slide()


func _on_pull_input_release() -> void:
	if not state_active:
		return
	set_property('flying', false)

