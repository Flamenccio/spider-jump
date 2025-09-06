extends CharacterBody2D

signal direction_updated(right: bool)

@export var _max_fly_speed: float = 1.0
@export var _min_fly_speed: float = 0.5
@export var _sting_time: float = 1.0
@export var _animator: AnimatedSprite2D

# Used as backup in case the wasp never meets death conditions
# (going on screen, then off screen)
var _life_timer: Timer = Timer.new()
var _player: Node2D
var _sting_animation_timer: Timer = Timer.new()
var _current_fly_velocity: Vector2
var _entered: bool = false

const LIFETIME = 10.0

func _ready() -> void:
	_sting_animation_timer.wait_time = _sting_time
	_sting_animation_timer.one_shot = true
	_sting_animation_timer.timeout.connect(func():
		velocity = _current_fly_velocity
		_animator.play('fly')
	)
	add_child(_sting_animation_timer)
	_player = GameConstants.player

	_life_timer.one_shot = true
	_life_timer.timeout.connect(func(): 
		print('wasp timeout')
		queue_free()
	)
	_life_timer.wait_time = LIFETIME
	add_child(_life_timer)


func set_fly_direction(right: bool) -> void:

	var horizontal_speed = randf_range(_min_fly_speed, _max_fly_speed)

	if right:
		velocity = Vector2(horizontal_speed, 0.0)
	else:
		velocity = Vector2(-horizontal_speed, 0.0)

	_current_fly_velocity = velocity
	direction_updated.emit(right)
	_life_timer.start()


func _physics_process(delta: float) -> void:
	# slowly move towards player
	var height_difference = _player.global_position.y - global_position.y
	velocity = Vector2(velocity.x, height_difference * 0.1)
	move_and_slide()


func _on_exit_screen() -> void:
	# Wasp starts off-screen, wait until it appears on-screen once
	# and leaves again before killing it
	if not _entered:
		return
	queue_free()


func _on_enter_screen() -> void:
	_entered = true


func _on_player_entered(body: Node2D) -> void:
	velocity = Vector2.ZERO
	_animator.play('sting')
	_sting_animation_timer.start()
