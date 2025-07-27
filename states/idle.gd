extends BehaviorState

@export var _animator: AnimatedSprite2D
@export var _gravity_scale: float = 1.0
@export var _player: CharacterBody2D

var _floor_suction_force: float = 5.0
var _down_vector: Vector2
signal player_entered_idle()

func enter_state() -> void:
	_down_vector = Vector2.from_angle(_player.rotation - (3 * PI / 2.0))
	set_property('jump', false)
	_animator.play('idle')
	player_entered_idle.emit()


func tick_state(delta: float) -> void:
	_player.move_and_collide(_down_vector * _floor_suction_force)

