extends Node2D

signal levelled_up(new_level: int)
signal on_game_over()
signal stamina_drained(amount: float)
signal score_updated(score: int)

## Base amount of stamina drained per second, from 0.0 - 1.0
@export var _base_stamina_drain_amount: float = 0.0
var _stamina_drain_amount: float = 0.0
var _old_stamina_drain: float = 0.0
var _pause_stamina_drain: bool = false

@export var _player: Node2D

const _LEVEL_UP_DRAIN_INCREASE = 0.01

func _ready() -> void:
	_stamina_drain_amount = _base_stamina_drain_amount
	PlayerEventBus.player_stat_updated.connect(func(stat: String, value):
		if stat == PlayerStatsInterface.STATS_SCORE:
			_on_score_updated(value)
	)
	PlayerEventBus.powerup_started.connect(func(powerup: String):
		if powerup == ItemIds.SUPER_GRUB_POWERUP:
			_old_stamina_drain = _stamina_drain_amount
			_stamina_drain_amount = 0.0
	)
	PlayerEventBus.powerup_ended.connect(func(powerup: String):
		if powerup == ItemIds.SUPER_GRUB_POWERUP:
			_stamina_drain_amount = _old_stamina_drain
	)

	# Pause drain
	PlayerEventBus.powerup_flash_start.connect(func(): _pause_stamina_drain = true)
	PlayerEventBus.powerup_flash_end.connect(func(): _pause_stamina_drain = false)


func game_over() -> void:
	get_tree().paused = true
	on_game_over.emit()


func _process(delta: float) -> void:
	if _pause_stamina_drain:
		return
	stamina_drained.emit(_stamina_drain_amount * delta * -1)
	var point = floori(_player.global_position.y / GameConstants.PIXELS_PER_POINT)
	score_updated.emit(point)


func _on_score_updated(score: int) -> void:
	var next_score = get_next_level_up_score(GameConstants.difficulty)
	if score >= next_score:
		_level_up(GameConstants.difficulty + 1)


func _level_up(next_level: int) -> void:
	GameConstants.difficulty = next_level
	_stamina_drain_amount += _LEVEL_UP_DRAIN_INCREASE
	levelled_up.emit(GameConstants.difficulty)


# TODO: adjust if needed
func get_next_level_up_score(difficulty: int) -> int:
	return 100 * (difficulty + 1) + 50 * difficulty
