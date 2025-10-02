extends BehaviorState

signal player_entered_idle()
signal normal_recheck_requested()

@export var _animator: SpriteTree
@export var _player: CharacterBody2D

var _floor_suction_force: float = 0.5
var _down_vector: Vector2

# Used for motion detection
var _last_position: Vector2

# Lower values mean higher precision
const _MOTION_DETECTION_PRECISION = 0.10

func enter_state() -> void:

	_player.velocity = Vector2.ZERO
	_last_position = _player.global_position
	_down_vector = Vector2.from_angle(_player.rotation - (3 * PI / 2.0))
	set_param('jump', false)
	_animator.play_branch_animation('idle')
	player_entered_idle.emit()

	if GameConstants.current_powerup == ItemIds.BLINKFLY_POWERUP:
		GameConstants.current_gravity = GameConstants.DEFAULT_GRAVITY


func update_state(_delta: float) -> void:

	_player.move_and_collide(_down_vector * _floor_suction_force)

	if _motion_detected():
		normal_recheck_requested.emit()
		_last_position = _player.global_position


func _normal_updated(_normal: Vector2) -> void:
	_down_vector = Vector2.from_angle(_player.rotation - (3 * PI / 2.0))


func _motion_detected() -> bool:

	var snapped_last_position = _last_position.snappedf(_MOTION_DETECTION_PRECISION)
	var snapped_global_position = _player.global_position.snappedf(_MOTION_DETECTION_PRECISION)
	var motion_detected = snapped_last_position != snapped_global_position

	if motion_detected:
		# Snap to position to prevent player getting stuck at corners
		_player.global_position = snapped_global_position.round()

	return motion_detected
