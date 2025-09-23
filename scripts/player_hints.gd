extends Node

signal give_hint(hint: String)

func _ready() -> void:
    PlayerEventBus.powerup_started.connect(_on_powerup_started)
    PlayerEventBus.powerup_ended.connect(_on_powerup_ended)


func _on_powerup_started(powerup: String) -> void:
    give_hint.emit(StringTableServer.get_string("powerup_hints", "hint." + powerup))


func _on_powerup_ended(_powerup: String) -> void:
    give_hint.emit("")