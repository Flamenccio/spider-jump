extends ShapeCast2D

@export var _player_body: CharacterBody2D
@export var _cast_length := 1.0

func _physics_process(delta: float) -> void:

	if not enabled:
		return

	var velocity_normalized = _player_body.get_real_velocity().normalized()
	var player_rotation = _player_body.rotation

	if velocity_normalized.length() <= 0.0:
		return

	# Counter-rotate against player's rotation
	var new_target_position = velocity_normalized.rotated(-player_rotation) * _cast_length
	target_position = new_target_position
	DebugDraw2D.circle(self.to_global(new_target_position * 8), 3.0, 16, Color.RED, 1.0, delta)


func get_closest_collision_info() -> Dictionary:

	if collision_result.size() == 0:
		return {}
	if collision_result.size() == 1:
		return collision_result[0]

	var sorted_collisions = collision_result.duplicate(true)
	sorted_collisions.sort_custom(_distance_sort.bind(_player_body.global_position))
	return sorted_collisions[0]


func _distance_sort(collision_a: Dictionary, collision_b: Dictionary, target: Vector2) -> bool:
	return collision_a.get("point").distance_to(target) < collision_b.get("point").distance_to(target)
