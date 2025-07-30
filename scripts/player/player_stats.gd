extends Node

## Emitted when player loses all lives
signal player_died()

## Emitted when player loses one life.
## If `soft` is passed as `true`, does not return player to a safe
## position.
signal player_hurt()

signal stamina_updated(current_stamina: float)
signal health_updated(current_health: int)
signal score_updated(current_score: int)

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
	
	# Initiate
	stamina_updated.emit(stamina)
	health_updated.emit(lives)


func decrease_lives() -> void:
	if lives <= _MIN_LIVES:
		return
	player_hurt.emit()
	if not debug:
		lives = maxi(lives - 1, _MIN_LIVES)
	health_updated.emit(lives)
	change_stamina(1.0)
	if lives <= _MIN_LIVES:
		player_died.emit()


func change_stamina(amount: float) -> void:
	if debug:
		return
	stamina = clampf(stamina + amount, _MIN_STAMINA, _MAX_STAMINA)
	stamina_updated.emit(stamina)
	if stamina <= _MIN_STAMINA:
		stamina = _MAX_STAMINA
		decrease_lives()


func update_score(new_score: int) -> void:
	new_score = mini(new_score, score)
	if score != new_score:
		score = new_score
		score_updated.emit(abs(score))

