extends BehaviorState

@export var _animator: SpriteTree
@export var _player: CharacterBody2D
var motion: Vector2

func enter_state() -> void:
	_animator.play_branch_animation('fall')


func tick_state(delta: float) -> void:
	_player.velocity += Vector2(0.0, GameConstants.current_gravity * delta)
	_player.move_and_slide()
