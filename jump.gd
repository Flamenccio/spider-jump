extends PlayerAction

@export var _jump_force: float = 1.0
var _pull: Vector2

func _on_input_service_pull_input_change(pull_input:Vector2) -> void:
	_pull = pull_input


func _on_input_service_pull_release() -> void:
	_jump()


func _jump() -> void:
	if not action_active:
		return
	_player_rb.apply_impulse(-1 * _pull * _jump_force)
	print('jump: ', -1 * _pull * _jump_force)