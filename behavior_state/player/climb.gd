extends BehaviorState

signal climb_finished()

@export var _player: CharacterBody2D
var _climb_target: Vector2
var _climb_timer: Timer = Timer.new()
var _climb_origin: Vector2

const _CLIMB_VELOCITY = 10
const _CLIMB_DURATION = 0.20

func _ready() -> void:
	_climb_timer.wait_time = _CLIMB_DURATION
	_climb_timer.one_shot = true
	_climb_timer.timeout.connect(func(): climb_finished.emit())
	add_child(_climb_timer)


func enter_state() -> void:
	_climb_origin = _player.global_position
	_climb_timer.start()


func set_climb_target(to: Vector2) -> void:
	_climb_target = to


func exit_state() -> void:
	_player.velocity = Vector2.ZERO


func tick_state(delta: float) -> void:
	var to_target = (_climb_target - _player.global_position) * _CLIMB_VELOCITY
	_player.velocity = to_target
	_player.move_and_slide()
