class_name ControlCenterer
extends Node
## Updates the pivot offset of this node's parent to be centered.

var active := true
var _parent: Control

func _ready() -> void:
	if get_parent() is not Control:
		push_error("Parent is not Control")
		return
	_parent = get_parent()


func _process(delta: float) -> void:
	if not active:
		return
	_parent.pivot_offset = _parent.size / 2.0
