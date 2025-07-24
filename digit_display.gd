class_name DigitDisplay
extends TextureRect

## Sprite should correspond to its index.
@export var digit_sprites: Array[Texture2D]
@export_range(0, 9) var _first_display: int = 0

func _ready() -> void:
	if digit_sprites.size() < 10:
		printerr('digit display: not enough sprites!')
		return
	display_digit(_first_display)


func display_digit(digit: int) -> void:
	digit = clampi(digit, 0, 9)
	texture = digit_sprites[digit]
