@tool
class_name SavedLevel
extends SavedNode

@export var tilemaps: Array[SavedTilemap]
@export var tilemap_colliders: Array[SavedTilemapCollider]
@export var level_objects: Array[SavedLevelObject]
## Height of the level, in pixels
@export var level_height: int
## Minimum difficulty level required for this level to spawn
@export var minimum_level: int = 0

var highest_tile_height: int = 99999
var lowest_tile_height: int = -99999

func instantiate() -> Node2D:

	var instance = Node2D.new()

	if saved_name == '':
		instance.name = 'Level'
	else:
		instance.name = saved_name

	# Instantiate tilemaps
	for tilemap in tilemaps:
		instance.add_child(tilemap.instantiate())

	# Instantiate tilemap colliders
	for collider in tilemap_colliders:
		instance.add_child(collider.instantiate())

	# Instantiate objects
	for object in level_objects:
		instance.add_child(object.instantiate())

	return instance


func save_level(level: Node2D, minimum_difficulty: int = 0, level_name: String = "Level") -> void:
	
	var children = level.get_children()
	minimum_level = minimum_difficulty
	saved_name = level_name.to_pascal_case()

	for child in children:

		if child is TileMapLayer:
			var saved_tilemap = SavedTilemap.new()
			saved_tilemap.save_tilemap(child as TileMapLayer)
			tilemaps.append(saved_tilemap)
			_calculate_height(child as TileMapLayer)
			print('found tilemap ', child.name)

		if child is StaticBody2D:
			var saved_tilemap_collider = SavedTilemapCollider.new()
			saved_tilemap_collider.save_collider(child as StaticBody2D)
			tilemap_colliders.append(saved_tilemap_collider)

		if child is LevelObject:
			var saved_object = SavedLevelObject.new()
			saved_object.save(child as LevelObject)
			level_objects.append(saved_object)


func _calculate_height(tilemap: TileMapLayer) -> void:

	for tile in tilemap.get_used_cells():
		highest_tile_height = mini(highest_tile_height, tile.y)
		lowest_tile_height = maxi(lowest_tile_height, tile.y)
	
	level_height = maxi(level_height, (lowest_tile_height - highest_tile_height) * tilemap.tile_set.tile_size.y)

