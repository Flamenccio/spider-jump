class_name FlashParticle
extends AnimatedSprite2D

func _ready() -> void:
	animation_finished.connect(_on_animation_finished)


func _on_animation_finished() -> void:
	if Engine.is_editor_hint():
		return
	queue_free()
