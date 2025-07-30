extends Sprite2D

@export var _active_sprite: Texture2D
@export var _inactive_sprite: Texture2D
@export var _start_active: bool = true

func _ready() -> void:
	if _start_active:
		set_active()
	else:
		set_inactive()


func set_active() -> void:
	texture = _active_sprite


func set_inactive() -> void:
	texture = _inactive_sprite
