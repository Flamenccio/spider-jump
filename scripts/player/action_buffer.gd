extends Node

# Buffered actions last this many physics frames before expiring
const _BUFFERED_ACTION_MAX_LIFETIME = 18

enum ActionType {
	JUMP,
}

var _buffered_actions: Array[BufferedAction]

func _ready() -> void:
	PlayerEventBus.player_fell.connect(func(_b): clear_buffered_actions())


func buffer_action(action_type: ActionType, action_value: Variant) -> void:

	var existing_idx = _buffered_actions.find_custom(_find_action_type.bind(action_type))
	if existing_idx >= 0:
		_buffered_actions.remove_at(existing_idx)

	_buffered_actions.append(BufferedAction.new(action_type, action_value))


func get_buffered_action_index(action_type: ActionType) -> int:
	return _buffered_actions.find_custom(_find_action_type.bind(action_type))


func pop_buffered_action(action_index: int) -> BufferedAction:
	if action_index < 0 or action_index >= _buffered_actions.size():
		push_warning("Action index outside of buffer range")
		return null
	return _buffered_actions.pop_at(action_index)


## Remove all buffered actions
func clear_buffered_actions() -> void:
	print("buffers cleared")
	_buffered_actions.clear()


func _find_action_type(buffered_action: BufferedAction, type: ActionType) -> bool:
	return buffered_action.action_type == type


func _physics_process(_delta: float) -> void:
	for i in _buffered_actions.size():
		if _buffered_actions[i].decrease_lifetime():
			_buffered_actions.remove_at(i)


class BufferedAction:

	var action_type: ActionType
	var action_value: Variant
	var frames_left := _BUFFERED_ACTION_MAX_LIFETIME

	func _init(type: ActionType, value: Variant) -> void:
		action_type = type
		action_value = value

	## Decreases this action's lifetime by 1. Returns [code]true[/code]
	## when the lifetime reaches 0.
	func decrease_lifetime() -> bool:
		frames_left = maxi(frames_left - 1, 0)
		return frames_left <= 0

