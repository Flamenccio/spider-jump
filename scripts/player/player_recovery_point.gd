extends VisibleOnScreenNotifier2D

func _ready() -> void:
	GameConstants.recovery_point = self


func _exit_tree() -> void:
	GameConstants.recovery_point = null
