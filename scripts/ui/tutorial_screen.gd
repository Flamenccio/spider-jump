extends Control

signal reached_tutorial_beginning()
signal reached_tutorial_end()
signal played_tutorial(tutorial_index: int)

const _TUTORIAL_PAGE_GROUP = "tutorial_page"

var _active_tutorial_page: Control
var _active_tutorial_page_index: int = -1
var _tutorial_pages: Array[Control]

## The index of the tutorial that will display by default.
## A value below 0 will not display anything.
@export var _default_tutorial_index: int = -1

func _ready() -> void:

	var tree = get_tree()
	_tutorial_pages.append_array(tree.get_nodes_in_group(_TUTORIAL_PAGE_GROUP))
	tree.call_group(_TUTORIAL_PAGE_GROUP, "stop_tutorial")
	tree.call_group(_TUTORIAL_PAGE_GROUP, "hide")

	if _default_tutorial_index >= 0:
		show_tutorial(_default_tutorial_index)


func show_tutorial(index: int) -> void:

	if index < 0 or index >= _tutorial_pages.size():
		return

	if _active_tutorial_page != null:
		_active_tutorial_page.hide()
		_active_tutorial_page.call("stop_tutorial")
	
	_active_tutorial_page = _tutorial_pages[index]
	_active_tutorial_page.show()
	_active_tutorial_page.call("play_tutorial")
	_active_tutorial_page_index = index
	played_tutorial.emit(index)


func stop_all_tutorials() -> void:
	_active_tutorial_page.hide()
	_active_tutorial_page.call("stop_tutorial")
	_active_tutorial_page_index = -1


func play_next_tutorial() -> void:
	var new_index = clampi(_active_tutorial_page_index + 1, 0, _tutorial_pages.size() - 1)
	if new_index == _active_tutorial_page_index:
		reached_tutorial_end.emit()
		return
	show_tutorial(new_index)


func play_previous_tutorial() -> void:
	var new_index = clampi(_active_tutorial_page_index - 1, 0, _tutorial_pages.size() - 1)
	if new_index == _active_tutorial_page_index:
		reached_tutorial_beginning.emit()
		return
	show_tutorial(new_index)

