extends BehaviorState

@export var _animator: AnimatedSprite2D
@export var _player: CharacterBody2D
@export var _gravity_acceleration: float = 1.0
var motion: Vector2

func enter_state() -> void:
	_animator.play('fall')


func tick_state(delta: float) -> void:
	_player.velocity += Vector2(0.0, _gravity_acceleration)
	_player.move_and_slide()


