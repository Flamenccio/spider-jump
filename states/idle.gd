extends BehaviorState

@export var _animator: AnimatedSprite2D
@export var _gravity_scale: float = 1.0
@export var _rb: RigidBody2D
@onready var gravity_force: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func enter_state() -> void:
	_animator.play('idle')


func tick_state(delta: float) -> void:
	var rotation_angle = _rb.rotation
	var down_angle = rotation_angle - 3 * PI / 2.0
	var down_vector = Vector2.from_angle(down_angle)
	var stick_force_magnitude = gravity_force * _gravity_scale
	_rb.apply_force(down_vector * stick_force_magnitude)
