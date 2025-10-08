extends AnimatedSprite2D

const _FLASH_NORMAL_FREQUENCY = 3.0
const _FLASH_URGENT_FREQUENCY = 10.0

## Switch to urgent flashing when invincibility timer drops below this value
const _FLASH_URGENT_DURATION_TRIGGER = 2.0
const _FLASH_FREQUENCY_PARAMETER = &"ghost_frequency"

var shader: ShaderMaterial
var _flashing := false
var _flash_timer := Timer.new()
var _urgent_flash_timer := Timer.new()

func _ready() -> void:
	shader = material as ShaderMaterial
	_flash_timer.timeout.connect(end_invincibility_flashing)
	_flash_timer.one_shot = true
	_urgent_flash_timer.timeout.connect(_start_urgent_flashing)
	_urgent_flash_timer.one_shot = true
	add_child(_flash_timer)
	add_child(_urgent_flash_timer)


func start_invincibility_flashing(invincibility_duration: float) -> void:

	if invincibility_duration <= 0.0:
		return

	_flashing = true

	if invincibility_duration <= 2.0:
		shader.set_shader_parameter(_FLASH_FREQUENCY_PARAMETER, _FLASH_URGENT_FREQUENCY)
		_flash_timer.start(invincibility_duration)
	else:
		_flash_timer.start(invincibility_duration)
		_urgent_flash_timer.start(invincibility_duration - _FLASH_URGENT_DURATION_TRIGGER) 
		shader.set_shader_parameter(_FLASH_FREQUENCY_PARAMETER, _FLASH_NORMAL_FREQUENCY)


func end_invincibility_flashing() -> void:
	if not _flashing:
		return
	_flashing = false
	shader.set_shader_parameter(_FLASH_FREQUENCY_PARAMETER, 0.0)


func _start_urgent_flashing() -> void:
	shader.set_shader_parameter(_FLASH_FREQUENCY_PARAMETER, _FLASH_URGENT_FREQUENCY)
