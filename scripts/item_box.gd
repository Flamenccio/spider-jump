@tool
class_name ItemBox
## Marks a location where an item could spawn.
##
## Placed in the level builder to set a place where a random
## item will spawn in.
extends LevelObject

@export var loot_table: Array[ItemBoxLoot]
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

class LootRoll:
	## Inclusive max
	var max_value: float
	## Exclusive min
	var min_value: float
	var loot: ItemBoxLoot

	func is_value_in_range(val: float) -> bool:
		return val <= max_value and val > min_value


## Spawn one of the items in `loot_table`, replacing this node.
func spawn_loot(current_level: int) -> void:

	if Engine.is_editor_hint():
		return

	# Filter items too high level
	loot_table = loot_table.filter(func(i: ItemBoxLoot): return i.minimum_level <= current_level)

	# Redistribute chances, if necessary
	var total_chance = 0.0
	total_chance = loot_table.reduce(func(accum: float, current: ItemBoxLoot): return accum + current.loot_chance, total_chance)
	var missing = 1.0 - total_chance
	
	if missing > 0.0:
		var split = missing / loot_table.size()
		for loot in loot_table:
			loot.loot_chance += split

	# Find random loot with percent chance
	var roll_table: Array[LootRoll]
	var last_value: float = 0
	for loot in loot_table:
		var roll = LootRoll.new()
		roll.min_value = last_value
		roll.max_value = last_value + loot.loot_chance
		last_value = roll.max_value
		roll.loot = loot
		roll_table.append(roll)
		
	var r = _rng.randf()
	var index = roll_table.find_custom(func(l: LootRoll): return l.is_value_in_range(r))
	if index < 0:
		print('item box: no loot in range')
		return
	_spawn_item(roll_table[index].loot)


func _spawn_item(item: ItemBoxLoot) -> void:
	if item.loot_scene == null:
		queue_free()
		return
	var instance = item.loot_scene.instantiate() as Node2D
	instance.position = position
	instance.rotation = rotation
	get_parent().call_deferred('add_child', instance)
	queue_free()


func get_local_properties() -> Dictionary:
	return {
		'loot_table': loot_table,
	}
