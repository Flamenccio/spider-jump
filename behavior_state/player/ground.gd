extends BehaviorState

signal grounded

func enter_state() -> void:
	grounded.emit()