extends BehaviorState

signal player_landed()

# If the vertical speed (absolute value of velocity.y)
# of the player falls below this value, triggers hang time
# gravity
const _HANG_TIME_TRIGGER_SPEED = 3.0
const _HANG_TIME_GRAVITY_MULTIPLIER = 0.25

# Max speeds
const _UNLIMITED_MAX_VERTICAL_SPEED = 1000.0

# Powerup gravity multipliers
const _ANTIBUG_GRAVITY_MULTIPLIER = -1.0
const _BUBBLEBEE_GRAVITY_MULTIPLIER = 0.5
const _HEAVY_BEETLE_GRAVITY_MULTIPLIER = 1.5

var _jumped := false
var _hang_time_enabled := true

@export var _animator: SpriteTree
@export var _player: CharacterBody2D

func _ready() -> void:
	PlayerEventBus.powerup_started.connect(_on_powerup_started)
	PlayerEventBus.powerup_ended.connect(_on_powerup_ended)


func enter_state() -> void:
	if GameConstants.current_powerup != ItemIds.BLINKFLY_POWERUP:
		_animator.play_branch_animation('fall')
	_jumped = get_param("jump") if get_param("jump") != null else true


func exit_state() -> void:
	player_landed.emit()


func update_state(delta: float) -> void:

	var current_vertical_velocity = _player.get_real_velocity().y
	var adjusted_gravity = GameConstants.current_gravity
	if _jumped and _hang_time_enabled and abs(current_vertical_velocity) <= _HANG_TIME_TRIGGER_SPEED:
		adjusted_gravity = GameConstants.current_gravity * _HANG_TIME_GRAVITY_MULTIPLIER

	_player.velocity += Vector2(0.0, adjusted_gravity * delta)
	_player.velocity = Vector2(
		_player.velocity.x, 
		clampf(
			_player.velocity.y, 
			-GameConstants.current_max_vertical_speed, 
			GameConstants.current_max_vertical_speed
		)
	)


func _on_powerup_started(powerup: String) -> void:
	match powerup:
		ItemIds.HOPPERPOP_POWERUP:
			GameConstants.current_max_vertical_speed = _UNLIMITED_MAX_VERTICAL_SPEED
		ItemIds.BLINKFLY_POWERUP:
			GameConstants.current_max_vertical_speed = _UNLIMITED_MAX_VERTICAL_SPEED
		ItemIds.BUBBLEBEE_POWERUP:
			_hang_time_enabled = false
			GameConstants.current_gravity *= _BUBBLEBEE_GRAVITY_MULTIPLIER
		ItemIds.ANTIBUG_POWERUP:
			GameConstants.current_gravity *= _ANTIBUG_GRAVITY_MULTIPLIER
		ItemIds.HEAVY_BEETLE_POWERUP:
			GameConstants.current_gravity *= _HEAVY_BEETLE_GRAVITY_MULTIPLIER
		_:
			return


func _on_powerup_ended(powerup: String) -> void:
	match powerup:
		ItemIds.HOPPERPOP_POWERUP:
			GameConstants.current_max_vertical_speed = GameConstants.DEFAULT_MAX_VERTICAL_SPEED
		ItemIds.BLINKFLY_POWERUP:
			GameConstants.current_max_vertical_speed = GameConstants.DEFAULT_MAX_VERTICAL_SPEED
		ItemIds.BUBBLEBEE_POWERUP:
			_hang_time_enabled = true
			GameConstants.current_gravity /= _BUBBLEBEE_GRAVITY_MULTIPLIER
		ItemIds.ANTIBUG_POWERUP:
			GameConstants.current_gravity /= _ANTIBUG_GRAVITY_MULTIPLIER
		ItemIds.HEAVY_BEETLE_POWERUP:
			GameConstants.current_gravity /= _HEAVY_BEETLE_GRAVITY_MULTIPLIER
		_:
			return
