extends Line2D

@export var _fixed_endpoint: Node2D
var _active = false

const START = 0
const END = 1

func _ready() -> void:
	if _fixed_endpoint == null:
		printerr('pull dragline: null fixed endpoint')
		return
	add_point(Vector2.ZERO, START)
	add_point(_fixed_endpoint.global_position, END)
	hide()


func pull_update(from: Vector2) -> void:
	if not _active:
		return
	from = (_fixed_endpoint.global_position + (from * 32))
	set_point_position(END, _fixed_endpoint.global_position)
	set_point_position(START, from)


func pull_set_active(active: bool) -> void:
	if active:
		show()
	else:
		hide()
	_active = active

