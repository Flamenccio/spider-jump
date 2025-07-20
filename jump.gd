extends PlayerAction

@export var _jump_force: float = 1.0
@export var _ground_raycast: RaycastCheck
var _pull: Vector2
var _standing_ground: Node2D

signal play_animation(animation: StringName)

func _on_input_service_pull_input_change(pull_input:Vector2) -> void:
	_pull = pull_input


func _on_input_service_pull_release() -> void:
	if not action_active:
		return
	_jump()


func _on_input_service_pull_press() -> void:
	if not action_active:
		return
	play_animation.emit('charge')


func _jump() -> void:
	var jump_direction = -1 * _pull * _jump_force
	var raycast_result = _ground_raycast.intersect_ray(jump_direction)

	"""
	# Parse raycast result
	if raycast_result.size() > 0 and raycast_result['collider'] is StaticBody2D:
		var raycast_body = raycast_result['collider'] as StaticBody2D
		var raycast_shape_owner = raycast_body.shape_owner_get_owner(raycast_result['shape'])

		# Do not jump if jumping onto the ground the player
		# is standing on
		if raycast_shape_owner == _standing_ground:
			return
	"""

	_player_rb.apply_impulse(jump_direction)
	play_animation.emit('jump')
