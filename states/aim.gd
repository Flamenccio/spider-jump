extends BehaviorState

@export var _rb: RigidBody2D
@export var _animator: AnimatedSprite2D
@export var _jump_force: float = 1.0
var _pull_input: Vector2

func enter_state() -> void:
	_animator.play('aim')


func _on_pull_release() -> void:
	if not state_active:
		return
	_jump()


func _on_pull_input_change(input: Vector2) -> void:
	if not state_active:
		return
	_pull_input = input


func _jump() -> void:
	var jump_vector = _pull_input * _jump_force * -1
	_rb.apply_impulse(jump_vector)

