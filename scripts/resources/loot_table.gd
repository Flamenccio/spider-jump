@tool
class_name LootTable
extends Resource

## Makes all loot rates the same
@export_tool_button('Equalize loot rates') var _equalize_loot_rates: Callable = _flatten_loot_rates
## Adjusts all loot rates so that the sum of all is 1.0
@export_tool_button('Make up loot rates') var _make_up: Callable = _make_up_loot_rates

@export var loot: Array[ItemBoxLoot]

func _make_up_loot_rates() -> void:
	if not Engine.is_editor_hint():
		return
	if loot.size() == 0:
		return
	var chances := loot.map(func(loot: ItemBoxLoot) -> float: return loot.loot_chance)
	var accum_chances = chances.reduce(func(accum: float, sum: float) -> float: return accum + sum)
	if accum_chances == 1.0:
		return
	var difference = 1.0 - accum_chances
	var distributed_difference = difference / loot.size()
	for l in loot:
		l.loot_chance += distributed_difference


func _flatten_loot_rates() -> void:
	if not Engine.is_editor_hint():
		return
	var equal = 1.0 / loot.size()
	for l in loot:
		l.loot_chance = equal

