@tool
extends StateMachineHandler

func _ready() -> void:
	super._ready()
	# Kinda not great but works
	PlayerEventBus.powerup_started.connect(func(powerup: String):
		if powerup == 'bubblebee':
			set_property('bubble', true)
	)
	PlayerEventBus.powerup_ended.connect(func(powerup: String):
		if powerup == 'bubblebee':
			set_property('bubble', false)
	)


func _powerup_started(powerup: String) -> void:
	set_property('powerup', powerup)


func _powerup_ended() -> void:
	set_property('powerup', 'none')

