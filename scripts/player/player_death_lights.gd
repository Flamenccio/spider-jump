extends Node2D

# Must be in a non-tool script to prevent Godot from
# crashing when playing animation in the editor
func _on_animation_finish() -> void:
	queue_free()
