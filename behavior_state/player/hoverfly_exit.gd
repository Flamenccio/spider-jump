extends BehaviorState

signal exited_hoverfly()

func enter_state() -> void:
	exited_hoverfly.emit()
