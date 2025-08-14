extends BehaviorState

signal player_entered_idle()
signal normal_recheck_requested()

@export var _animator: SpriteTree
@export var _gravity_scale: float = 1.0
@export var _player: CharacterBody2D

var _floor_suction_force: float = 0.5
var _down_vector: Vector2
# Used to prevent 'slipping' when the player lands on a corner
var _recheck_normal_timer: Timer = Timer.new()

# In seconds
const _RECHECK_NORMAL_FREQUENCY = 0.20

func _ready() -> void:
	_recheck_normal_timer.wait_time = _RECHECK_NORMAL_FREQUENCY
	_recheck_normal_timer.timeout.connect(func(): normal_recheck_requested.emit())
	add_child(_recheck_normal_timer)


func enter_state() -> void:
	_down_vector = Vector2.from_angle(_player.rotation - (3 * PI / 2.0))
	set_property('jump', false)
	_animator.play_branch_animation('idle')
	player_entered_idle.emit()
	_recheck_normal_timer.start()


func exit_state() -> void:
	_recheck_normal_timer.stop()


func tick_state(delta: float) -> void:
	_player.move_and_collide(_down_vector * _floor_suction_force)


func _normal_updated(normal: Vector2) -> void:
	_down_vector = Vector2.from_angle(_player.rotation - (3 * PI / 2.0))
