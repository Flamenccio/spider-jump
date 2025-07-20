@tool
class_name SavedLevel
extends SavedNode

@export var tilemaps: Array[SavedTilemap]
@export var tilemap_colliders: Array[SavedTilemapCollider]
## Height of the level, in pixels
@export var level_height: int

func instantiate() -> Node2D:
	var instance = Node2D.new()
	instance.name = saved_name

	# Instantiate tilemaps
	for tilemap in tilemaps:
		instance.add_child(tilemap.instantiate())

	# Instantiate tilemap colliders
	for collider in tilemap_colliders:
		instance.add_child(collider.instantiate())

	return instance


func save_level(level: Node2D) -> void:
	
	var children = level.get_children()

	for child in children:

		if child is TileMapLayer:
			var saved_tilemap = SavedTilemap.new()
			saved_tilemap.save_tilemap(child as TileMapLayer)
			tilemaps.append(saved_tilemap)
			_calculate_height(child as TileMapLayer)

		if child is StaticBody2D:
			var saved_tilemap_collider = SavedTilemapCollider.new()
			saved_tilemap_collider.save_collider(child as StaticBody2D)
			tilemap_colliders.append(saved_tilemap_collider)


func _calculate_height(tilemap: TileMapLayer) -> void:

	# Find highest and lowest points
	var highest: int = 0
	var lowest: int = 0

	for tile in tilemap.get_used_cells():
		highest = mini(highest, tile.y)
		lowest = maxi(lowest, tile.y)
	
	level_height = maxi(level_height, lowest - highest)

