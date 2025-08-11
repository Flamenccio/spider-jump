@tool
extends StateMachineHandler

func _powerup_started(powerup: String) -> void:
	print('new powerup: ', powerup)
	set_property('powerup', powerup)


func _powerup_ended() -> void:
	set_property('powerup', 'none')

