extends Node2D

signal levelled_up(new_level: int)
signal on_game_over()
signal stamina_drained(amount: float)
signal score_updated(score: int)
signal pause_screen_enabled()
signal pause_screen_disabled()
signal game_exited()

const _LEVEL_UP_DRAIN_INCREASE = 0.005
const _MAIN_MENU_UID = "uid://ive8w8v858du"

var _stamina_drain_amount: float = 0.0
var _old_stamina_drain: float = 0.0
var _pause_stamina_drain: bool = false
var _player: Node2D
var _game_paused := false
var _pause_screen_animation_complete := true

## Base amount of stamina drained per second, from 0.0 - 1.0
@export var _debug_initial_difficulty: int = 0
@export var _base_stamina_drain_amount: float = 0.0

func _ready() -> void:

	_player = GameConstants.player
	_stamina_drain_amount = _base_stamina_drain_amount
	GameConstants.difficulty = _debug_initial_difficulty

	if _debug_initial_difficulty > 0:
		levelled_up.emit(_debug_initial_difficulty)

	PlayerEventBus.player_stat_updated.connect(func(stat: String, value):
		if stat == PlayerStatsInterface.STATS_SCORE:
			_on_score_updated(value)
	)
	PlayerEventBus.powerup_started.connect(func(powerup: String):
		call_deferred('_remove_all_powerups')
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


# Replaces all existing powerup items with yumfly
func _remove_all_powerups() -> void:
	get_tree().call_group('powerup', 'remove_powerup')


func game_over() -> void:
	get_tree().paused = true
	on_game_over.emit()


func _process(delta: float) -> void:
	if _pause_stamina_drain or _game_paused:
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


func _on_pause_toggle() -> void:

	if not _pause_screen_animation_complete:
		return
	
	_pause_screen_animation_complete = false

	if _game_paused:
		pause_screen_disabled.emit()
	else:
		pause_screen_enabled.emit()
	_game_paused = not _game_paused
	get_tree().paused = _game_paused


func _on_pause_screen_animation_done() -> void:
	_pause_screen_animation_complete = true


func _on_game_exit() -> void:
	if not _game_paused:
		return
	get_tree().paused = false
	if get_tree().change_scene_to_file(ResourceUID.uid_to_path(_MAIN_MENU_UID)) != OK:
		push_error("error occured when exiting to main menu")
		return


func _on_pause_screen_pause_screen_button_pressed(button: String) -> void:
	match button:
		"exit":
			game_exited.emit()
		"resume":
			_on_pause_toggle()
		_:
			return
