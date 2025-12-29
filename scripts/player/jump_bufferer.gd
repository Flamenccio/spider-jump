extends Node

var _active := false
var _valid_state := false
var _valid_powerup := true
var _pull_input := Vector2.ZERO

@onready var _action_buffer := %ActionBuffer

func _ready() -> void:
	PlayerEventBus.powerup_started.connect(_on_powerup_started)
	PlayerEventBus.powerup_ended.connect(_on_powerup_ended)


func _on_state_machine_transited(_from: String, to) -> void:
	_valid_state = to == "Fall"
	_update_active()


func _on_powerup_started(powerup: String) -> void:
	_valid_powerup = powerup != ItemIds.HOVERFLY_POWERUP
	_update_active()


func _on_powerup_ended(_powerup: String) -> void:
	_valid_powerup = true
	_update_active()


func _update_active() -> void:
	_active = _valid_state and _valid_powerup


func _on_pull_released() -> void:
	if not _active:
		return
	if _pull_input.length() == 0.0:
		return
	_action_buffer.buffer_action(_action_buffer.ActionType.JUMP, _pull_input)


func _on_pull_updated(input: Vector2) -> void:
	_pull_input = input

