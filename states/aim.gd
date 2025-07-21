extends BehaviorState

@export var _player: CharacterBody2D
@export var _animator: AnimatedSprite2D
@export var _jump_force: float = 1.0
var _pull_input: Vector2
var _jumped: bool = false

func enter_state() -> void:
	_animator.play('aim')


func exit_state() -> void:
	_jumped = false


func _on_pull_release() -> void:
	if not state_active:
		return
	_jump()


func _on_pull_input_change(input: Vector2) -> void:
	if not state_active:
		return
	_pull_input = input


func _jump() -> void:
	if _jumped:
		return
	var _jump_vector = _pull_input * _jump_force * -1
	_player.velocity = _jump_vector
	_jumped = true


func tick_state(delta: float) -> void:
	if not _jumped:
		return
	_player.move_and_slide()
	
