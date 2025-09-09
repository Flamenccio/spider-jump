class_name FlashParticle
extends AnimatedSprite2D

enum ExpirationType {
	## The flash particle will expire once its animation ends
	ANIMATION_END,
	## The flash particle will expire once it loops some amount
	## specified by `expiration_loops`.
	ANIMATION_LOOP
}

var expiration_type: ExpirationType = ExpirationType.ANIMATION_END
var expiration_loops: int
var _loops: int = 0

func _ready() -> void:
	animation_finished.connect(_on_animation_finished)
	animation_looped.connect(_on_animation_looped)


func _on_animation_finished() -> void:
	if Engine.is_editor_hint() or expiration_type != ExpirationType.ANIMATION_END:
		return
	queue_free()


func _on_animation_looped() -> void:
	if Engine.is_editor_hint() or expiration_type != ExpirationType.ANIMATION_LOOP:
		return
	if _loops >= expiration_loops:
		queue_free()
		return
	_loops += 1
