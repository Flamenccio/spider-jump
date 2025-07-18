extends BehaviorState

signal airborne()

func enter_state() -> void:
	print('air')
	airborne.emit()