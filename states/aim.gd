extends BehaviorState

## Emitted when player succesfully jumps
signal aim_entered()
signal player_jumped()
signal trajectory_updated(velocity: Vector2, acceleration: Vector2)

@export var _player: CharacterBody2D
@export var _animator: SpriteTree
@export var _jump_force: float = 1.0
@export var _particle_emitter: Node

var _pull_input: Vector2
var _jumped: bool = false
var _surface_normal: Vector2
var _powerup: String = ''

const _MAX_SHAPECAST_RESULTS = 4
const _HOPPERPOP_MULTIPLIER = 1.6
const _BUBBLEBEE_MULTIPLIER = 1.2
const _HEAVY_BEETLE_MULTIPLIER = 1.0

func _ready() -> void:
	PlayerEventBus.powerup_started.connect(func(powerup: String):
		match powerup:
			'hopperpop':
				_jump_force *= _HOPPERPOP_MULTIPLIER
				_powerup = powerup
			'bubblebee':
				_jump_force /= _BUBBLEBEE_MULTIPLIER
				_powerup = powerup
			'heavy_beetle':
				_jump_force *= _HEAVY_BEETLE_MULTIPLIER
	)
	PlayerEventBus.powerup_ended.connect(func(powerup: String):
		match powerup:
			'hopperpop':
				_jump_force /= _HOPPERPOP_MULTIPLIER
				_powerup = ''
			'bubblebee':
				_jump_force *= _BUBBLEBEE_MULTIPLIER
				_powerup = ''
			'heavy_beetle':
				_jump_force /= _HEAVY_BEETLE_MULTIPLIER
	)


func enter_state() -> void:
	set_property('jump', false)
	aim_entered.emit()
	_animator.play_branch_animation('aim')


func exit_state() -> void:
	_jumped = false


func _on_pull_release() -> void:
	if not state_active:
		return
	_jump()


func _on_pull_input_change(input: Vector2) -> void:
	if not state_active:
		return
	_pull_input = input

	# Emit predicted trajectory
	var velocity = _pull_input * _jump_force * -1
	var acceleration = Vector2(0, GameConstants.current_gravity)
	trajectory_updated.emit(velocity, acceleration)


func _jump() -> void:

	if _jumped:
		return

	var _jump_vector = _pull_input * _jump_force * -1

	if not _is_jump_direction_valid(_jump_vector):
		return

	set_property('jump', true)
	_player.velocity = _jump_vector
	_jumped = true
	player_jumped.emit()

	# Spawn particles
	match _powerup:
		'hopperpop':
			_particle_emitter.spawn_hopperpop_jump_dust()
		'bubblebee':
			_particle_emitter.spawn_bubblebee_jump_dust()
		_:
			_particle_emitter.spawn_jump_dust()


func tick_state(delta: float) -> void:
	if not _jumped:
		return
	_player.move_and_slide()


func _is_jump_direction_valid(direction: Vector2) -> bool:
	var dot = floorf(direction.dot(_surface_normal))
	return dot > 0.0 or _surface_normal == Vector2.ZERO


func _on_normal_land(normal: Vector2) -> void:
	_surface_normal = normal


func _on_leave_ground() -> void:
	_surface_normal = Vector2.ZERO

