extends Line2D

@export var _hoverfly_color: Color
@export var _normal_color: Color
@export var _invalid_color: Color

@export var _fixed_endpoint: Node2D
var _active = false
var _current_max_distance: float
var _blinkfly_hide: bool = false

const START = 0
const END = 1

const _MAX_DISTANCE = 32.0
const _MAX_HOVER_DISTANCE = 48.0

func _ready() -> void:
	if _fixed_endpoint == null:
		printerr('pull dragline: null fixed endpoint')
		return
	_current_max_distance = _MAX_DISTANCE
	PlayerEventBus.powerup_started.connect(_handle_powerup)
	PlayerEventBus.powerup_ended.connect(_handle_powerup_end)
	PlayerEventBus.player_aim.connect(_on_player_aim)
	add_point(Vector2.ZERO, START)
	add_point(_fixed_endpoint.global_position, END)
	hide()


func pull_update(from: Vector2) -> void:
	if not _active:
		return
	from = (_fixed_endpoint.global_position + (from * _current_max_distance))
	set_point_position(END, _fixed_endpoint.global_position)
	set_point_position(START, from)


func pull_set_active(active: bool) -> void:
	if _blinkfly_hide:
		return
	if active:
		show()
	else:
		hide()
	_active = active


func _handle_powerup(powerup: String) -> void:
	if powerup == ItemIds.HOVERFLY_POWERUP:
		_current_max_distance = _MAX_HOVER_DISTANCE
		default_color = _hoverfly_color
	elif powerup == ItemIds.BLINKFLY_POWERUP:
		_blinkfly_hide = true
		hide()


func _handle_powerup_end(powerup: String) -> void:
	if powerup == ItemIds.HOVERFLY_POWERUP:
		_current_max_distance = _MAX_DISTANCE
		default_color = _normal_color
	elif powerup == ItemIds.BLINKFLY_POWERUP:
		_blinkfly_hide = false
		show()


func _on_player_aim(_direction: Vector2, is_valid: bool) -> void:

	var is_hoverfly = GameConstants.current_powerup == ItemIds.HOVERFLY_POWERUP

	if not is_valid and not is_hoverfly:
		default_color = _invalid_color
	elif is_valid and not is_hoverfly:
		default_color = _normal_color
	elif is_hoverfly:
		default_color = _hoverfly_color

