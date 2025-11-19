extends Node2D

signal levelled_up(new_level: int)
signal on_game_over()
signal score_updated(score: int)
signal pause_screen_enabled()
signal pause_screen_disabled()
signal game_exited()
signal game_restarted()

const _MAIN_MENU_UID = "uid://ive8w8v858du"
const _GAME_SCENE_UID = "uid://c3vqs430qpt8w"

var _player: Node2D
var _game_paused := false
var _pause_screen_animation_complete := true

@export var _game_screen_transition: ScreenTransition
@export var _game_spawner: GlobalSpawner

## Base amount of stamina drained per second, from 0.0 - 1.0
@export var _debug_initial_difficulty: int = 0


func _enter_tree() -> void:
	GameConstants.game_spawner = _game_spawner


func _ready() -> void:

	_player = GameConstants.player
	GameConstants.difficulty = _debug_initial_difficulty

	if _debug_initial_difficulty > 0:
		levelled_up.emit(_debug_initial_difficulty)

	PlayerEventBus.player_stat_updated.connect(func(stat: String, value):
		if stat == PlayerStatsInterface.STATS_SCORE:
			_on_score_updated(value)
	)
	PlayerEventBus.powerup_started.connect(func(_powerup: String):
		call_deferred('_remove_all_powerups')
	)

	# Play some music
	GlobalSoundManager.play_music("spider_jump")


func game_over() -> void:
	get_tree().paused = true
	on_game_over.emit()


# Replaces all existing powerup items with yumfly
func _remove_all_powerups() -> void:
	get_tree().call_group('powerup', 'remove_powerup')


func _process(delta: float) -> void:
	var point = floori(_player.global_position.y / GameConstants.PIXELS_PER_POINT)
	score_updated.emit(point)


func _on_score_updated(score: int) -> void:
	var next_score = get_next_level_up_score(GameConstants.difficulty)
	if score >= next_score:
		_level_up(GameConstants.difficulty + 1)


func _level_up(next_level: int) -> void:
	GameConstants.difficulty = next_level
	levelled_up.emit(GameConstants.difficulty)


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
	GlobalSoundManager.stop_music()
	_game_screen_transition.enter_transition_finished.connect(_exit_game, ConnectFlags.CONNECT_ONE_SHOT)
	_game_screen_transition.play_enter_animation()


func _exit_game() -> void:
	get_tree().paused = false
	if get_tree().change_scene_to_file(ResourceUID.uid_to_path(_MAIN_MENU_UID)) != OK:
		push_error("error occured when exiting to main menu")
		return
	game_exited.emit()


func _on_game_restart() -> void:
	GlobalSoundManager.stop_music()
	_game_screen_transition.enter_transition_finished.connect(_restart_game, ConnectFlags.CONNECT_ONE_SHOT)
	_game_screen_transition.play_enter_animation()


func _restart_game() -> void:
	get_tree().paused = false
	if get_tree().change_scene_to_file(ResourceUID.uid_to_path(_GAME_SCENE_UID)) != OK:
		push_error("error occured when restarting game")
		return
	game_restarted.emit()


func _on_pause_screen_pause_screen_button_pressed(button: String) -> void:
	match button:
		"exit":
			_on_game_exit()
		"resume":
			_on_pause_toggle()
		"restart":
			_on_game_restart()
		_:
			return
