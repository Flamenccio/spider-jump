extends BehaviorState

@export var _animator: AnimatedSprite2D
@export var _player: CharacterBody2D
@export var _gravity_acceleration: float = 1.0
var motion: Vector2

func enter_state() -> void:
	_animator.play('fall')
	motion = get_shared_variable('momentum')


func tick_state(delta: float) -> void:
	motion += Vector2(0.0, _gravity_acceleration)
	_player.velocity = motion
	_player.move_and_slide()


