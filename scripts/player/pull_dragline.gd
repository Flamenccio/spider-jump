extends Line2D

@export var _fixed_endpoint: Node2D
var _active = false
var _current_max_distance: float

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
	if active:
		show()
	else:
		hide()
	_active = active


func _handle_powerup(powerup: String) -> void:
	if powerup == 'hoverfly':
		_current_max_distance = _MAX_HOVER_DISTANCE


func _handle_powerup_end(_powerup: String) -> void:
	_current_max_distance = _MAX_DISTANCE

