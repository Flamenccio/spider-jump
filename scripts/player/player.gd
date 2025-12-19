extends CharacterBody2D

# External use
signal danger_entered()

# Any
signal stop_moving()
signal moving()

signal invincibility_started(duration: float)
signal invincibility_ended()

# Used for invincibility after getting hurt
var _invincibility_timer: Timer = Timer.new()

var _movement_paused := false

# In seconds
const _DEFAULT_INVINCIBILITY_TIME = 6.0

func _ready() -> void:
	_invincibility_timer.one_shot = true
	_invincibility_timer.timeout.connect(func():
		invincibility_ended.emit()
	)
	add_child(_invincibility_timer)
	GameConstants.player = self
	GlobalInputServer.pull_origin = self
	
	PlayerEventBus.player_fell.connect(_on_player_fell)
	PlayerEventBus.powerup_flash_start.connect(func(): _movement_paused = true)
	PlayerEventBus.powerup_flash_end.connect(func(): _movement_paused = false)


func _physics_process(_delta: float) -> void:
	if velocity.length() <= 0:
		return
	if not _movement_paused and move_and_slide():
		PlayerEventBus.player_collision_enter.emit(get_last_slide_collision())


func force_update_collision() -> void:
	if move_and_slide():
		PlayerEventBus.player_collision_enter.emit(get_last_slide_collision())


func on_level_up_platform_reached() -> void:
	GameConstants.recovery_point.global_position = global_position


func _rotate_against_normal(normal: Vector2) -> void:
	# The player UP vector must match the given normal
	var up_angle := rotation - PI / 2.0
	var up_vector := Vector2.from_angle(up_angle)
	var difference := up_vector.angle_to(normal)
	rotation += difference


func _on_danger_entered() -> void:
	danger_entered.emit()


func _on_player_fell(_here: Vector2) -> void:
	_start_invincibility(_DEFAULT_INVINCIBILITY_TIME)


func _start_invincibility(time: float) -> void:
	_invincibility_timer.stop()
	_invincibility_timer.start(time)
	invincibility_started.emit(time)


func _on_move_updated(move_input: Vector2) -> void:
	if move_input.length() > 0:
		moving.emit()
	else:
		stop_moving.emit()
