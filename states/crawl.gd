extends BehaviorState

@export var _player: CharacterBody2D
@export var _move_speed: float = 1.0
var _move_input: Vector2

func _on_move_input_change(input: Vector2) -> void:
	_move_input = input


func tick_state(delta: float) -> void:

	var horizontal = _move_input - Vector2(0, _move_input.y)
	var crawl_vector = horizontal.rotated(_player.rotation)

	# Only move and collide when input is given
	if crawl_vector.length() == 0:
		set_shared_variable('momentum', Vector2.ZERO)
		return

	var movement = crawl_vector * _move_speed * delta
	_player.move_and_collide(movement)
	set_shared_variable('momentum', movement)

