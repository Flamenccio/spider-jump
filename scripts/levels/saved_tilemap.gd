@tool
class_name SavedTilemap
extends SavedNode

@export var offset: Vector2
@export var pattern: TileMapPattern
@export var tile_set: TileSet

func instantiate() -> Node2D:

	var instance = TileMapLayer.new()
	instance.tile_set = tile_set
	instance.set_pattern(offset, pattern)
	instance.name = saved_name

	return instance


func save_tilemap(tilemap: TileMapLayer) -> void:

	if not Engine.is_editor_hint():
		return

	var cells = tilemap.get_used_cells()
	var tilemap_pattern = tilemap.get_pattern(cells)
	var tilemap_offset = _find_tilemap_pattern_origin_cell(cells)
	offset = tilemap_offset
	pattern = tilemap_pattern
	tile_set = tilemap.tile_set
	saved_name = tilemap.name


func _find_tilemap_pattern_origin_cell(cells: Array[Vector2i]) -> Vector2i:

	"""
	The origin of a tilemap pattern is the top-left
	corner of the smallest box that encapsulates all
	used cells.
	"""

	var highest_y = 0
	var lowest_x = 0

	for cell in cells:
		highest_y = mini(cell.y, highest_y)
		lowest_x = mini(cell.x, lowest_x)

	return Vector2i(lowest_x, highest_y)
