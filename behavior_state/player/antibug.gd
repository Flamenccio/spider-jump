extends BehaviorState

func enter_state() -> void:
	# Workaround to allow normal player control
	set_property('powerup', 'none')
