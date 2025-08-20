@tool
extends StateMachineHandler

var pause_tick: bool = false

func _ready() -> void:
	super._ready()

	if Engine.is_editor_hint():
		return

	PlayerEventBus.powerup_started.connect(func(powerup: String):
		set_property('powerup', powerup)
		if powerup == ItemIds.BUBBLEBEE_POWERUP:
			set_property('bubble', true)
	)
	PlayerEventBus.powerup_ended.connect(func(powerup: String):
		set_property('powerup', ItemIds.NO_POWERUP)
		if powerup == ItemIds.BUBBLEBEE_POWERUP:
			set_property('bubble', false)
	)

	# Pause tick state
	PlayerEventBus.powerup_flash_start.connect(func(): pause_tick = true)
	PlayerEventBus.powerup_flash_end.connect(func(): pause_tick = false)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not pause_tick and _active_state != null:
		_active_state.tick_state(delta)
