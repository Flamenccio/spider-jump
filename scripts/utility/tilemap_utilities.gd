class_name TileMapUtilities

## Get the union of all collision layers this tilemap is on.
static func get_tilemap_collision_layers(tilemap: TileMapLayer) -> int:
	var layer := 0
	var tileset = tilemap.tile_set
	for t in tileset.get_physics_layers_count():
		layer |= tileset.get_physics_layer_collision_layer(t)
	return layer


## Get the union of all collision masks this tilemap has.
static func get_tilemap_collision_masks(tilemap: TileMapLayer) -> int:
	var mask := 0
	var tileset = tilemap.tile_set
	for t in tileset.get_physics_layers_count():
		mask |= tileset.get_physics_layer_collision_mask(t)
	return mask


## Get the indexes of physics layers that contain collision layers [code]layers[/code].
##
## If [code]exclusive[/code] is [b]true[/b], physics layers are only counted when their
## collision layers equal [b]exactly[/b] [code]layers[/code]. Otherwise, physics layers
## are counted their collision layers contain at least one bit from [code]layers[/code].
static func get_physics_layers_collision_layers(tilemap: TileMapLayer, layers: int, exclusive := false) -> Array[int]:
	var tileset := tilemap.tile_set
	var valid: Array[int]
	for t in tileset.get_physics_layers_count():
		if exclusive and tileset.get_physics_layer_collision_layer(t) != layers:
			valid.append(t)
		if not exclusive and tileset.get_physics_layer_collision_layer(t) | layers > 0:
			valid.append(t)
	return valid


## Get the indexes of physics layers that contain collision mask [code]mask[/code].
##
## If [code]exclusive[/code] is [b]true[/b], physics layers are only counted when their
## collision masks equal [b]exactly[/b] [code]mask[/code]. Otherwise, physics layers
## are counted their collision mask contain at least one bit from [code]mask[/code].
static func get_physics_layers_collision_mask(tilemap: TileMapLayer, mask: int, exclusive := true) -> Array[int]:
	var tileset := tilemap.tile_set
	var valid: Array[int]
	for t in tileset.get_physics_layers_count():
		if exclusive and tileset.get_physics_layer_collision_layer(t) != mask:
			valid.append(t)
		if not exclusive and tileset.get_physics_layer_collision_layer(t) | mask > 0:
			valid.append(t)
	return valid

