@tool
extends StaticBody2D

@export_tool_button('Bake!') var _bake_call: Callable = _bake
@export var _target_tilemap_layer: TileMapLayer
var _tiles_cache: Array[Vector2i]


func _bake() -> void:

	if not Engine.is_editor_hint():
		return

	if _target_tilemap_layer == null:
		printerr('bake tilemap: target tilemap layer is null!')
		return

	print("bake tilemap: baking...")

	_flush_children()
	_tiles_cache = _target_tilemap_layer.get_used_cells()

	var groups := _find_groups()

	_generate_polygons(groups)


func _flush_children() -> void:
	var children = get_children()
	for child in children:
		child.queue_free()


func _find_groups() -> Dictionary:

	var group_num: int = 0
	var groups: Dictionary
	print("bake tilemap: grouping cells...")

	while _tiles_cache.size() > 0:
		groups[group_num] = _group_cells(_tiles_cache.pick_random())
		print("bake tilemap: created group ", group_num)
		group_num += 1
	
	print('bake tilemap: found {0} groups'.format({'0': group_num}))
	return groups


func _group_cells(current: Vector2i) -> Array[Vector2i]:

	if not _tiles_cache.has(current):
		return []

	var group: Array[Vector2i] = []
	group.append(current)
	_tiles_cache.erase(current)

	var right = current + Vector2i.RIGHT
	var left = current + Vector2i.LEFT
	var up = current + Vector2i.UP
	var down = current + Vector2i.DOWN

	group.append_array(_group_cells(up))
	group.append_array(_group_cells(down))
	group.append_array(_group_cells(right))
	group.append_array(_group_cells(left))

	return group


func _generate_polygons(groups: Dictionary) -> void:
	var shapes: Dictionary
	for key in groups.keys():
		shapes[key] = _merge_shape(groups[key])


## Returns a list of vertices, travelling clockwise around
## the resulting polygon
func _merge_shape(group: Array[Vector2i]) -> Array[Vector2i]:
	var begin = _find_merge_start(group)
	return []


## Returns top-left position
func _find_merge_start(group: Array[Vector2i]) -> Vector2i:
	var begin: Vector2i = Vector2i(99999, 99999)
	for pos in group:
		if pos.x < begin.x or pos.y < begin.y:
			begin = pos
	return begin