extends Node

signal move_input_change(move_input: Vector2)

var _current_move_input: Vector2 = Vector2.ZERO


func _input(event: InputEvent) -> void:
	_handle_move_input(event)


func _handle_move_input(event: InputEvent) -> void:

	var temp_input := _current_move_input

	# Press actions

	if event.is_action_pressed('move_down'):
		temp_input += Vector2.DOWN
	
	if event.is_action_pressed('move_up'):
		temp_input += Vector2.UP

	if event.is_action_pressed('move_right'):
		temp_input += Vector2.RIGHT

	if event.is_action_pressed('move_left'):
		temp_input += Vector2.LEFT

	# Release actions

	if event.is_action_released('move_down'):
		temp_input -= Vector2.DOWN

	if event.is_action_released('move_up'):
		temp_input -= Vector2.UP

	if event.is_action_released('move_right'):
		temp_input -= Vector2.RIGHT

	if event.is_action_released('move_left'):
		temp_input -= Vector2.LEFT
	
	if _current_move_input != temp_input:
		move_input_change.emit(temp_input)
		_current_move_input = temp_input