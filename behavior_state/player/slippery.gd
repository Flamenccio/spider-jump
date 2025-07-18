extends BehaviorState

signal slippery_grounded()

func enter_state() -> void:
	slippery_grounded.emit()