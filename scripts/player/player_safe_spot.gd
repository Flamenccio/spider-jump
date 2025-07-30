extends VisibleOnScreenNotifier2D

var in_screen: bool = false

func _on_screen_entered() -> void:
	in_screen = true


func _on_screen_exited() -> void:
	in_screen = false
