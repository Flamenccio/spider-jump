extends AnimatedSprite2D

var flash_timer: Timer = Timer.new()
var ghost: bool = false
var shader: ShaderMaterial
var current_flash_timer_duration: float

const I_FLASH_BASE_FREQUENCY = 0.5
const I_FLASH_FREQUENCY_INCREASE = 0.025
const I_FLASH_MIN_FREQUENCY = 0.05
const GHOST_PARAMETER = &"ghost"

func _ready() -> void:
	shader = material as ShaderMaterial
	flash_timer.timeout.connect(func():
		_toggle_ghost()
		_reset_flash_timer()
	)
	flash_timer.one_shot = true
	add_child(flash_timer)


func _activate_invincibility_flashing() -> void:
	flash_timer.stop()
	current_flash_timer_duration = I_FLASH_BASE_FREQUENCY
	flash_timer.start(current_flash_timer_duration)


func _reset_flash_timer() -> void:
	current_flash_timer_duration = maxf(current_flash_timer_duration - I_FLASH_FREQUENCY_INCREASE, I_FLASH_MIN_FREQUENCY)
	flash_timer.start(current_flash_timer_duration)


func _toggle_ghost() -> void:
	ghost = not ghost
	shader.set_shader_parameter(GHOST_PARAMETER, ghost)


func _stop_invincibility_flashing() -> void:
	flash_timer.stop()
	current_flash_timer_duration = I_FLASH_BASE_FREQUENCY
	shader.set_shader_parameter(GHOST_PARAMETER, false)
	ghost = false

