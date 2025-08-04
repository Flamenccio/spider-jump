extends Node

## Emitted when player loses all lives
signal player_died()

## Emitted when player loses one life.
signal player_hurt()

@export var debug: bool = false

var lives: int
const _MAX_LIVES = 3
const _MIN_LIVES = 0

var stamina: float
const _MAX_STAMINA = 1.0
const _MIN_STAMINA = 0.0

var score: int
const _MIN_SCORE = 0
const _MAX_SCORE = 999999

func _ready() -> void:
	lives = _MAX_LIVES
	stamina = _MAX_STAMINA

	# Connect to player stats interface
	PlayerStatsInterface.change_stat.connect(handle_stats_change_request, ConnectFlags.CONNECT_DEFERRED)
	PlayerStatsInterface.set_stat.connect(handle_stats_set_request, ConnectFlags.CONNECT_DEFERRED)
	
	# Initiate
	PlayerEventBus.player_stat_updated.emit('stamina', stamina)
	PlayerEventBus.player_stat_updated.emit('lives', lives)


func decrease_lives() -> void:
	if lives <= _MIN_LIVES:
		return
	player_hurt.emit()
	if not debug:
		lives = maxi(lives - 1, _MIN_LIVES)
	PlayerEventBus.player_stat_updated.emit('lives', lives)
	change_stamina(1.0)
	if lives <= _MIN_LIVES:
		player_died.emit()


func change_stamina(amount: float) -> void:
	if debug:
		return
	stamina = clampf(stamina + amount, _MIN_STAMINA, _MAX_STAMINA)
	PlayerEventBus.player_stat_updated.emit('stamina', stamina)
	if stamina <= _MIN_STAMINA:
		stamina = _MAX_STAMINA
		decrease_lives()


func update_score(new_score: int) -> void:
	new_score = mini(new_score, score)
	if score != new_score:
		score = new_score
		PlayerEventBus.player_stat_updated.emit('score', abs(score))


func handle_stats_change_request(stat: String, change: Variant) -> void:

	if stat == '' or stat == null:
		push_warning('player stats: empty stat name supplied')
		return

	match stat:
		'lives':
			if change != 0:
				push_warning('player stats: change value for lives stat ignored')
			decrease_lives()
		'stamina':
			change_stamina(change)
		'score':
			var new_score = change + score
			update_score(new_score)
		_:
			push_error('player stats: no such stats with id "{0}"'.format({'0': stat}))
			return


func handle_stats_set_request(stat: String, value: Variant) -> void:
	if stat == '' or stat == null:
		push_warning('player stats: empty stat name supplied')
		return
	match stat:
		'lives':
			push_warning('player stats: unable to set player lives')
			return
		'stamina':
			var change = value - stamina
			change_stamina(change)
		'score':
			update_score(value)
		_:
			push_error('player stats: no such stats with id "{0}"'.format({'0': stat}))
			return

