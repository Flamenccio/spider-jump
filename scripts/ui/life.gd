extends TextureRect

@export var _flash_sprite: Texture2D
@export var _full_sprite: Texture2D
@export var _empty_sprite: Texture2D
@export var _start_full: bool = true
var _flash_timer: Timer = Timer.new()
var _next_texture: Texture2D

const _FLASH_DURATION = 0.10

func _ready() -> void:

	if _full_sprite == null or _empty_sprite == null or _flash_sprite == null:
		printerr('life hud: empty sprites!')
		return
	if _start_full:
		texture = _full_sprite
	else:
		texture = _empty_sprite

	_flash_timer.wait_time = _FLASH_DURATION
	_flash_timer.one_shot = true
	_flash_timer.timeout.connect(func(): texture = _next_texture)
	add_child(_flash_timer)


func set_full() -> void:
	_flash(_full_sprite)


func set_empty() -> void:
	_flash(_empty_sprite)


func _flash(next_texture: Texture2D) -> void:
	_next_texture = next_texture
	texture = _flash_sprite
	_flash_timer.start()

