extends AnimatedSprite2D

var _active: bool = false

func _ready() -> void:
	deactivate_cursor()
	PlayerEventBus.powerup_started.connect(func(powerup: String):
		if powerup == ItemIds.BLINKFLY_POWERUP:
			activate_cursor()
	)
	PlayerEventBus.powerup_ended.connect(func(powerup: String):
		if powerup == ItemIds.BLINKFLY_POWERUP:
			deactivate_cursor()
	)


func _process(delta: float) -> void:
	if not _active:
		return
	global_position = get_global_mouse_position()


func deactivate_cursor() -> void:
	hide()
	_active = false


func activate_cursor() -> void:
	show()
	_active = true
