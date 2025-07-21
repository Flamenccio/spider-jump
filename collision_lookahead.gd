extends ShapeCast2D

signal on_body_collided(body_rid: RID, body: Node, shape_index: int)

@export var _player: CharacterBody2D
var locked: bool = false


func _physics_process(delta: float) -> void:
	# Sweep
	if locked:
		return
	var motion = _player.get_last_motion()
	if motion == Vector2.ZERO:
		enabled = false
		return
	target_position = _player.global_position + motion
	force_shapecast_update()

	var results := collision_result
	for result in results:
		call_deferred('signal_deferred', get_collider(result['rid']), result['collider_id'], result['shape'])


func signal_deferred(rid: RID, body: Node, shape_index: int) -> void:
	on_body_collided.emit(rid, body, shape_index)


func disable() -> void:
	locked = true
	enabled = false


func enable(lock: bool = false) -> void:
	locked = lock
	enabled = true

