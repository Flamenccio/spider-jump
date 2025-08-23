@tool
extends StateMachineHandler

var pause_tick: bool = false

func _ready() -> void:
	super._ready()

	if Engine.is_editor_hint():
		return

	PlayerEventBus.powerup_started.connect(func(powerup: String):
		_state_machine_player.set_param('powerup', powerup)
		if powerup == ItemIds.BUBBLEBEE_POWERUP:
			_state_machine_player.set_param('bubble', true)
	)
	PlayerEventBus.powerup_ended.connect(func(powerup: String):
		_state_machine_player.set_param('powerup', ItemIds.NO_POWERUP)
		if powerup == ItemIds.BUBBLEBEE_POWERUP:
			_state_machine_player.set_param('bubble', false)
	)

	# Pause tick state
	PlayerEventBus.powerup_flash_start.connect(func(): pause_tick = true)
	PlayerEventBus.powerup_flash_end.connect(func(): pause_tick = false)


func _on_state_update(_s: String, delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not pause_tick and active_state != null:
		active_state.update_state(delta)

