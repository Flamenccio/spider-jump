class_name UIScreen
extends Control
## Represents a GUI menu that takes up the entire screen

signal screen_hidden()
signal screen_revealed()

## Ignore these nodes when hiding/showing all elements
@export var _ignore_nodes: Array[Control]

## If `true`, runs `hide_all_elements` on `_ready`.
@export var _start_hidden := false

func _ready() -> void:
	if _start_hidden:
		hide_all_elements()


func hide_screen() -> void:
	print("{0}: hiding screen".format({"0": name}))
	hide()
	screen_hidden.emit()


func reveal_screen() -> void:
	print("{0}: revealing screen".format({"0": name}))
	show()
	screen_revealed.emit()


## Hides all elements, excluding those in `_ignore_nodes`, without
## triggering `screen_hidden`.
func hide_all_elements() -> void:
	for child in get_children():
		if child is not Control or _ignore_nodes.has(child):
			continue
		child.hide()


## Shows all elements, excluding those in `_ignore_nodes`, without
## triggering `screen_revealed`.
func show_all_elements() -> void:
	for child in get_children():
		if child is not Control or _ignore_nodes.has(child):
			continue
		child.show()