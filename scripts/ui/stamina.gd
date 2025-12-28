extends TextureProgressBar

const _FLASH_DURATION = 0.10

var _flash_timer: Timer = Timer.new()
var _replenish_effect_timer := Timer.new()
var _last_value := 0.0
var _replenish_effect_shader: ShaderMaterial
var _replenish_effect_active := false

@export var _flash_sprite: Texture2D
@export var _normal_sprite: Texture2D

@onready var _replenish_effect := %StaminaBarReplenishEffect

func _ready() -> void:

	_replenish_effect_shader = _replenish_effect.material as ShaderMaterial
	_replenish_effect_shader.set_shader_parameter("animate", false)

	_flash_timer.wait_time = _FLASH_DURATION
	_flash_timer.one_shot = true
	_flash_timer.timeout.connect(func(): texture_progress = _normal_sprite)
	add_child(_flash_timer)

	var total_frames = _replenish_effect_shader.get_shader_parameter("cols") * _replenish_effect_shader.get_shader_parameter("rows")
	_replenish_effect_timer.wait_time = total_frames / _replenish_effect_shader.get_shader_parameter("fps")
	_replenish_effect_timer.timeout.connect(_deactivate_replenish_effect)
	add_child(_replenish_effect_timer)


func _process(_delta: float) -> void:
	if _replenish_effect_active:
		_replenish_effect_shader.set_shader_parameter("current_time", Time.get_ticks_msec() / 1000.0)


## Called when the stamina bar progress changes
func _flash() -> void:
	if _flash_timer.time_left > 0:
		return
	texture_progress = _flash_sprite
	_flash_timer.start()


func _on_value_changed(v: float) -> void:
	if v > _last_value:
		_replenish_effect_timer.stop()
		var m = Time.get_ticks_msec() / 1000.0
		_replenish_effect_shader.set_shader_parameter("start_time", m)
		_replenish_effect_shader.set_shader_parameter("animate", true)
		_replenish_effect_timer.start()
		_replenish_effect_active = true
	_last_value = v


func _deactivate_replenish_effect() -> void:
	_replenish_effect_shader.set_shader_parameter("animate", false)
	_replenish_effect_active = false