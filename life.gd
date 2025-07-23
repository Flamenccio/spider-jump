extends TextureRect

@export var _full_sprite: Texture2D
@export var _empty_sprite: Texture2D
@export var _start_full: bool = true

func _ready() -> void:
	if _full_sprite == null or _empty_sprite == null:
		printerr('life hud: empty sprites!')
		return
	if _start_full:
		set_full()


func set_full() -> void:
	texture = _full_sprite


func set_empty() -> void:
	texture = _empty_sprite

