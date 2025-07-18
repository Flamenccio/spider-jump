extends BehaviorState

signal airborne()

func enter_state() -> void:
	airborne.emit()