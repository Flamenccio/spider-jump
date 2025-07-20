extends PlayerAction

@export var _jump_force: float = 1.0
var _pull: Vector2

signal jump_charge()
signal jump_release()

func _on_input_service_pull_input_change(pull_input:Vector2) -> void:
	_pull = pull_input


func _on_input_service_pull_release() -> void:
	_jump()
	jump_release.emit()


func _on_input_service_pull_press() -> void:
	jump_charge.emit()


func _jump() -> void:
	if not action_active:
		return
	_player_rb.apply_impulse(-1 * _pull * _jump_force)
