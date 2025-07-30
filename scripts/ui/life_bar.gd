extends HFlowContainer

@export var parent: Control
var items: Array[TextureRect]
var _current_item: int = 0

signal life_lost(screen_coords: Transform2D)

func _ready() -> void:
	# Get children and sort them by x-axis
	var children = get_children()
	children.sort_custom(func(a: TextureRect, b: TextureRect): return a.position.x < b.position.x)
	for child in children:
		if child is not TextureRect:
			continue
		items.append(child as TextureRect)
	_current_item = items.size() - 1


func display_life(life: int) -> void:
	life -= 1
	life = clampi(life, 0, items.size() - 1)
	var difference = life - _current_item
	change_life(difference)


func change_life(change: int) -> void:
	if change == 0:
		return
	for i in range(abs(change)):
		if change < 0:
			# Reduce life
			items[_current_item].call('set_empty')
			_current_item -= 1
			life_lost.emit(parent)
		else:
			# Increase life
			_current_item += 1
			items[_current_item].call('set_full')
