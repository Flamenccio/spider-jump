@tool
class_name LootTable
extends Resource

@warning_ignore("unused_private_class_variable")
@export_tool_button("Reset weights") var _reset_all_weights: Callable = _reset_weights

@export var loot: Array[ItemBoxLoot]

func _reset_weights() -> void:
	for l in loot:
		l.chance_weight = 0.0


@warning_ignore("unused_private_class_variable")
func _make_up_loot_rates() -> void:
	if not Engine.is_editor_hint():
		return
	if loot.size() == 0:
		return
	var chances := loot.map(func(l: ItemBoxLoot) -> float: return l.chance_weight)
	var accum_chances = chances.reduce(func(accum: float, sum: float) -> float: return accum + sum)
	if accum_chances == 1.0:
		return
	var difference = 1.0 - accum_chances
	var distributed_difference = difference / loot.size()
	for l in loot:
		l.chance_weight += distributed_difference


@warning_ignore("unused_private_class_variable")
func _flatten_loot_rates() -> void:
	if not Engine.is_editor_hint():
		return
	var equal = 1.0 / loot.size()
	for l in loot:
		l.chance_weight = equal

