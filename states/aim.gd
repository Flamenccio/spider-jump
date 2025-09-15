extends BehaviorState

## Emitted when player succesfully jumps
signal aim_entered()
signal player_jumped()
signal trajectory_updated(velocity: Vector2, acceleration: Vector2)
signal player_blinkfly_jumped()

const _MAX_SHAPECAST_RESULTS = 4
const _HOPPERPOP_MULTIPLIER = 1.6
const _BUBBLEBEE_MULTIPLIER = 0.83
const _HEAVY_BEETLE_MULTIPLIER = 1.0
const _SUPER_GRUB_MULTIPLIER = 1.12
const _BLINKFLY_MULTIPLIER = 5.0
const _MAX_BLINKFLY_DISTANCE = 200.0
const _GROUND_LAYER = 2
const _SLIP_LAYER = 4

var _pull_input: Vector2
var _jumped: bool = false
var _surface_normal: Vector2
var _powerup: String = 'none'

@export var _ground_check: RaycastCheck
@export var _player: CharacterBody2D
@export var _animator: SpriteTree
@export var _jump_force: float = 1.0
@export var _particle_emitter: Node

func _ready() -> void:
	PlayerEventBus.powerup_started.connect(func(powerup: String):
		_powerup = powerup
		match powerup:
			ItemIds.HOPPERPOP_POWERUP:
				_jump_force *= _HOPPERPOP_MULTIPLIER
			ItemIds.BUBBLEBEE_POWERUP:
				_jump_force *= _BUBBLEBEE_MULTIPLIER
			ItemIds.HEAVY_BEETLE_POWERUP:
				_jump_force *= _HEAVY_BEETLE_MULTIPLIER
			ItemIds.SUPER_GRUB_POWERUP:
				_jump_force *= _SUPER_GRUB_MULTIPLIER
			ItemIds.BLINKFLY_POWERUP:
				_jump_force *= _BLINKFLY_MULTIPLIER
	)
	PlayerEventBus.powerup_ended.connect(func(powerup: String):
		_powerup = ItemIds.NO_POWERUP
		match powerup:
			ItemIds.HOPPERPOP_POWERUP:
				_jump_force /= _HOPPERPOP_MULTIPLIER
			ItemIds.BUBBLEBEE_POWERUP:
				_jump_force /= _BUBBLEBEE_MULTIPLIER
			ItemIds.HEAVY_BEETLE_POWERUP:
				_jump_force /= _HEAVY_BEETLE_MULTIPLIER
			ItemIds.SUPER_GRUB_POWERUP:
				_jump_force /= _SUPER_GRUB_MULTIPLIER
			ItemIds.BLINKFLY_POWERUP:
				_jump_force /= _BLINKFLY_MULTIPLIER
	)


func enter_state() -> void:
	set_param('jump', false)
	if _powerup != ItemIds.BLINKFLY_POWERUP:
		aim_entered.emit()
	_animator.play_branch_animation('aim')


func exit_state() -> void:
	_jumped = false


func update_state(delta: float) -> void:
	if not _jumped:
		return
	_player.move_and_slide()


func _on_pull_release() -> void:
	if not state_active:
		return
	if _powerup == ItemIds.BLINKFLY_POWERUP:
		_blinkfly_jump()
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

	set_param('jump', true)
	_player.velocity = _jump_vector
	_jumped = true
	player_jumped.emit()

	# Spawn particles
	match _powerup:
		ItemIds.HOPPERPOP_POWERUP:
			_particle_emitter.spawn_hopperpop_jump_dust()
		ItemIds.BUBBLEBEE_POWERUP:
			_particle_emitter.spawn_bubblebee_jump_dust()
		_:
			_particle_emitter.spawn_jump_dust()


func _is_jump_direction_valid(direction: Vector2) -> bool:
	var dot = floorf(direction.dot(_surface_normal))
	return dot > 0.0 or _surface_normal == Vector2.ZERO


func _on_normal_land(normal: Vector2) -> void:
	_surface_normal = normal


func _on_leave_ground() -> void:
	_surface_normal = Vector2.ZERO


func _blinkfly_jump() -> void:

	if _jumped:
		return

	var ray_offset = _pull_input.normalized() * _MAX_BLINKFLY_DISTANCE
	var ray_destination = ray_offset + _player.global_position

	if not _is_jump_direction_valid(ray_offset):
		return

	var results = _ground_check.intersect_ray(ray_destination)

	if results.size() == 0:
		return

	var valid_landing := (results["collider"] as CollisionObject2D).collision_layer == _GROUND_LAYER
	if not valid_landing:
		return

	_animator.play_branch_animation('warp')
	set_param('jump', true)
	_player.velocity = _pull_input.normalized() *  _jump_force
	_jumped = true
	player_blinkfly_jumped.emit()
	_particle_emitter.spawn_jump_dust()

