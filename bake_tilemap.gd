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
	var begin = group.pick_random()
	_merge_cell(begin, [], group)

	return []


# Attempts to merge `cell` to `polygon`
func _merge_cell(cell: Vector2i, polygon: Array[Vector2i], group: Array[Vector2i]) -> void:

	if not group.has(cell):
		return

	group.erase(cell)
	var cell_data := _target_tilemap_layer.get_cell_tile_data(cell)
	var cell_vertices := cell_data.get_collision_polygon_points(0, 0)

	if polygon.size() > 0:

		# Find overlapping points
		var overlap = _get_intersection(cell_vertices, polygon)

		if overlap.size() == 0:
			printerr('bake tilemap: no overlapping points found! cannot merge')
			return

		print('bake tilemap: merged!')

	else:
		polygon = cell_vertices
	
	var up = cell + Vector2i.UP
	var down = cell + Vector2i.DOWN
	var left = cell + Vector2i.LEFT
	var right = cell + Vector2i.RIGHT

	_merge_cell(up, polygon, group)
	_merge_cell(down, polygon, group)
	_merge_cell(left, polygon, group)
	_merge_cell(right, polygon, group)


func _get_intersection(a: Array[Vector2i], b: Array[Vector2i]) -> Array[Vector2i]:
	var intersection: Array[Vector2i] = []
	for element in a:
		if b.has(element):
			intersection.append(element)
	return intersection