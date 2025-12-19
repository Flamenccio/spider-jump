extends BehaviorState

signal climb_finished()

const _CLIMB_VELOCITY = 50
const _CLIMB_DURATION = 2.0 / 60.0
const _CLIMB_DURATION_MULTIPLIER_HEAVY_BEETLE = 50.0 / 60.0

var _climb_target: Vector2
var _climb_timer: Timer = Timer.new()
var _climb_origin: Vector2

@export var _player: CharacterBody2D

func _ready() -> void:

	_climb_timer.wait_time = _CLIMB_DURATION
	_climb_timer.one_shot = true
	_climb_timer.timeout.connect(func(): 
		set_param('climb', false)
	)
	add_child(_climb_timer)

	PlayerEventBus.powerup_started.connect(func(powerup: String):
		if powerup == ItemIds.HEAVY_BEETLE_POWERUP:
			_climb_timer.wait_time *= _CLIMB_DURATION_MULTIPLIER_HEAVY_BEETLE
	)
	PlayerEventBus.powerup_ended.connect(func(powerup: String):
		if powerup == ItemIds.HEAVY_BEETLE_POWERUP:
			_climb_timer.wait_time /= _CLIMB_DURATION_MULTIPLIER_HEAVY_BEETLE
	)


func enter_state() -> void:
	_player.velocity = Vector2.ZERO
	_climb_origin = _player.global_position
	_climb_timer.start()


func set_climb_target(to: Vector2) -> void:
	_climb_target = to


func exit_state() -> void:
	_player.velocity = Vector2.ZERO
	_player.global_position = _climb_target
	climb_finished.emit()


func update_state(_delta: float) -> void:
	#var to_target = (_climb_target - _player.global_position) * _CLIMB_VELOCITY
	#_player.velocity = to_target
	pass

