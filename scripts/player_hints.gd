extends Node

signal give_hint(hint: String)

const _HINT_PREFIX = "hint."

func _ready() -> void:
    PlayerEventBus.powerup_started.connect(_on_powerup_started)
    PlayerEventBus.powerup_ended.connect(_on_powerup_ended)


func _on_powerup_started(powerup: String) -> void:
    give_hint.emit(tr(_HINT_PREFIX + powerup))


func _on_powerup_ended(_powerup: String) -> void:
    give_hint.emit("")