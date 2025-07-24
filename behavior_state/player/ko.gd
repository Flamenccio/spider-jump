extends BehaviorState

signal player_koed()
signal player_recovered()

@export var _player: CharacterBody2D
@export var _ko_gravity = 9.8
@export var _ko_jump_force = 3.0

var _gravity_vector: Vector2
var _player_collision_mask: int

func _ready() -> void:
	_gravity_vector = Vector2(0.0, _ko_gravity)


func enter_state() -> void:
	_player_collision_mask = _player.collision_mask
	_player.collision_mask = 0
	_player.velocity = Vector2(0.0, -abs(_ko_jump_force))
	player_koed.emit()


func exit_state() -> void:
	_player.velocity = Vector2.ZERO
	_player.collision_mask = _player_collision_mask
	player_recovered.emit()


func tick_state(delta: float) -> void:
	_player.move_and_slide()
	_player.velocity = _player.velocity + _gravity_vector
