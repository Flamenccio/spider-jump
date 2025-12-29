@tool
class_name ItemBox
extends LevelObject
## Marks a location where an item could spawn.
##
## Placed in the level builder to set a place where a random
## item will spawn in.

@export var loot_table: LootTable

## Spawn one of the items in `loot_table_override`, replacing this node.
func spawn_loot(current_level: int) -> void:

	if Engine.is_editor_hint():
		return

	# Filter items too high level
	var available_loot = loot_table.loot.filter(func(i: ItemBoxLoot): return i.minimum_level <= current_level)

	# Get total weight
	var total_weight = available_loot.reduce(func(accum: float, loot: ItemBoxLoot): return accum + loot.chance_weight, 0)

	# Roll
	var select = randf_range(0.0, total_weight)
	var chance_accum := 0.0
	for loot: ItemBoxLoot in available_loot:
		if loot.chance_weight + chance_accum >= select and chance_accum < select:
			_spawn_item(loot)
			return
		chance_accum += loot.chance_weight

	print("No loot in range")


func _spawn_item(item: ItemBoxLoot) -> void:
	if item.item_data == null:
		queue_free()
		return
	var instance = item.item_data.instantiate_item()
	instance.position = position
	instance.rotation = rotation
	get_parent().call_deferred('add_child', instance)
	queue_free()


func get_local_properties() -> Dictionary:
	return {
		'loot_table': loot_table,
	}
