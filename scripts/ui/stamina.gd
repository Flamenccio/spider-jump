extends TextureProgressBar

@export var _flash_sprite: Texture2D
@export var _normal_sprite: Texture2D
var _flash_timer: Timer = Timer.new()

const _FLASH_DURATION = 0.10

func _ready() -> void:
	_flash_timer.wait_time = _FLASH_DURATION
	_flash_timer.one_shot = true
	_flash_timer.timeout.connect(func(): texture_progress = _normal_sprite)
	add_child(_flash_timer)


## Called when the stamina bar progress changes
func _flash() -> void:
	if _flash_timer.time_left > 0:
		return
	texture_progress = _flash_sprite
	_flash_timer.start()

