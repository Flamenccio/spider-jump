extends BehaviorState

func _machine_ready() -> void:
	set_shared_variable('momentum', Vector2.ZERO)
