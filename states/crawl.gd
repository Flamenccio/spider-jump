extends BehaviorState

signal player_crawled()
signal player_stopped_crawl()

@export var _player: CharacterBody2D
@export var _move_speed: float = 1.0
var _move_input: Vector2

const _HEAVY_BEETLE_MULTIPLIER = 5.0
const _SUPER_GRUB_MULTIPLIER = 1.8
const _BLINKFLY_MULTILPIER = 1.6

func _ready() -> void:
	PlayerEventBus.powerup_started.connect(func(powerup: String):
		match powerup:
			ItemIds.HEAVY_BEETLE_POWERUP:
				_move_speed *= _HEAVY_BEETLE_MULTIPLIER
			ItemIds.SUPER_GRUB_POWERUP:
				_move_speed *= _SUPER_GRUB_MULTIPLIER
			ItemIds.BLINKFLY_POWERUP:
				_move_speed *= _BLINKFLY_MULTILPIER
	)
	PlayerEventBus.powerup_ended.connect(func(powerup: String):
		match powerup:
			ItemIds.HEAVY_BEETLE_POWERUP:
				_move_speed /= _HEAVY_BEETLE_MULTIPLIER
			ItemIds.SUPER_GRUB_POWERUP:
				_move_speed /= _SUPER_GRUB_MULTIPLIER
			ItemIds.BLINKFLY_POWERUP:
				_move_speed /= _BLINKFLY_MULTILPIER
	)


func enter_state() -> void:
	player_crawled.emit()
	set_param('jump', false)


func exit_state() -> void:
	player_stopped_crawl.emit()


func _on_move_input_change(input: Vector2) -> void:
	_move_input = input


func update_state(delta: float) -> void:

	var horizontal = _move_input - Vector2(0, _move_input.y)
	var crawl_vector = horizontal.rotated(_player.rotation)

	# Only move and collide when input is given
	if crawl_vector.length() == 0:
		_player.velocity = Vector2.ZERO
		return

	var movement = crawl_vector * _move_speed
	_player.velocity = movement
	_player.move_and_slide()

