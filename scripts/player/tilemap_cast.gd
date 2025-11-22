extends ShapeCast2D

@export var _player_body: CharacterBody2D

func _physics_process(delta: float) -> void:

	if not enabled:
		return

	var velocity_normalized = _player_body.get_real_velocity().normalized()
	var player_rotation = _player_body.rotation

	if velocity_normalized.length() <= 0.0:
		return

	# Counter-rotate against player's rotation
	var new_target_position = velocity_normalized.rotated(-player_rotation)
	target_position = new_target_position
	DebugDraw2D.circle(self.to_global(new_target_position * 8), 3.0, 16, Color.RED, 1.0, delta)
