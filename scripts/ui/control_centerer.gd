class_name ControlCenterer
extends Node
## Updates the pivot offset of this node's parent to be centered.

var poll := false
var _parent: Control

func _ready() -> void:
	if get_parent() is not Control:
		push_error("Parent is not Control")
		return
	_parent = get_parent()


func _process(delta: float) -> void:
	if not poll:
		return
	_parent.pivot_offset = _parent.size / 2.0


func activate_polling() -> void:
	poll = true


func deactivate_polling() -> void:
	poll = false


func center_parent() -> void:
	_parent.pivot_offset = _parent.size / 2.0

