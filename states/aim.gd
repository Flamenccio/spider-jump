extends BehaviorState

## Emitted when player succesfully jumps
signal player_jumped()

@export var _player: CharacterBody2D
@export var _animator: AnimatedSprite2D
@export var _jump_force: float = 1.0

var _pull_input: Vector2
var _jumped: bool = false
var _surface_normal: Vector2

const _MAX_SHAPECAST_RESULTS = 4

func enter_state() -> void:
	set_property('jump', false)
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

	if not _is_jump_direction_valid(_jump_vector):
		return

	set_property('jump', true)
	_player.velocity = _jump_vector
	_jumped = true
	player_jumped.emit()


func tick_state(delta: float) -> void:
	if not _jumped:
		return
	_player.move_and_slide()


func _is_jump_direction_valid(direction: Vector2) -> bool:
	var dot = floorf(direction.dot(_surface_normal))
	return dot > 0.0


func _on_normal_land(normal: Vector2) -> void:
	_surface_normal = normal
