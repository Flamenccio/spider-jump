extends BehaviorState

@export var _animator: AnimatedSprite2D
@export var _gravity_scale: float = 1.0
@export var _player: CharacterBody2D

func enter_state() -> void:
	set_shared_variable('momentum', Vector2.ZERO)
	_animator.play('idle')


func tick_state(delta: float) -> void:
	"""
	var rotation_angle = _player.rotation
	var down_angle = rotation_angle - 3 * PI / 2.0
	var down_vector = Vector2.from_angle(down_angle)
	var stick_force_magnitude = gravity_force * _gravity_scale
	_player.apply_force(down_vector * stick_force_magnitude)
	"""
