extends Node

## Emitted when player loses all lives
signal player_died()

# TODO: make an option where the player does not
# return to safe spot (losing stamina mid jump)

## Emitted when player loses one life
signal player_hurt()

signal stamina_updated(current_stamina: float)
signal health_updated(current_health: int)

var lives: int
const _MAX_LIVES = 3
const _MIN_LIVES = 0

var stamina: float
const _MAX_STAMINA = 1.0
const _MIN_STAMINA = 0.0

func _ready() -> void:
	lives = _MAX_LIVES
	stamina = _MAX_STAMINA


func decrease_lives() -> void:
	if lives <= _MIN_LIVES:
		return
	player_hurt.emit()
	lives = maxi(lives - 1, _MIN_LIVES)
	health_updated.emit(lives)
	if lives <= _MIN_LIVES:
		player_died.emit()


func change_stamina(amount: float) -> void:
	stamina = clampf(stamina + amount, _MIN_STAMINA, _MAX_STAMINA)
	stamina_updated.emit(stamina)
	if stamina <= _MIN_STAMINA:
		stamina = _MAX_STAMINA
		decrease_lives()

