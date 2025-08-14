extends BehaviorState

## Powerups that change player behavior
@export var _behavior_powerups: Array[String]

func enter_state() -> void:
	var powerup = get_property('powerup')
	if not _behavior_powerups.has(powerup):
		set_property('powerup', 'none')
