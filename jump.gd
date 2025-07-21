extends PlayerAction

@export var _jump_force: float = 1.0
@export var _ground_raycast: RaycastCheck
var _pull: Vector2
var _standing_ground: Node2D

signal play_animation(animation: StringName)

func _on_input_service_pull_input_change(pull_input:Vector2) -> void:
	#_pull = pull_input
	pass


func _on_input_service_pull_release() -> void:
	"""
	if not action_active:
		return
	_jump()
	"""
	pass


func _on_input_service_pull_press() -> void:
	"""
	if not action_active:
		return
	play_animation.emit('charge')
	"""
	pass


func _jump() -> void:
	"""
	var jump_direction = -1 * _pull * _jump_force
	_player_rb.apply_impulse(jump_direction)
	play_animation.emit('jump')
	"""
	pass
