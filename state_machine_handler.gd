@tool
extends Node
class_name StateMachineHandler

@export var _machine: Node
var _behaviors: Array[BehaviorState]
var _active_state: BehaviorState

@export_tool_button('Add states') var _add_states_button: Callable = _add_states

# Variables that behaviors can share with each other
var _state_machine_variables: Dictionary

func _add_states() -> void:

	if not Engine.is_editor_hint():
		return

	for child in get_children():
		if child is BehaviorState:
			child.free()

	var states = _machine.state_machine.states
	var editor_root = get_tree().edited_scene_root
	for entry in states.keys():
		var new_state = BehaviorState.new()
		new_state.name = entry
		add_child(new_state)
		new_state.owner = editor_root


func _ready() -> void:

	if Engine.is_editor_hint():
		return

	var children = get_children()
	assert(children.size() > 0, 'state machine handler must have behavior states as its children')
	for child in children:
		if child is not BehaviorState:
			continue
		_behaviors.append(child as BehaviorState)
	
	# Supply callables
	for behavior: BehaviorState in _behaviors:
		behavior.set_state_machine_property = set_property
		behavior.set_shared_state_machine_variable = set_shared_variable
		behavior.get_shared_state_machine_variable = get_shared_variable
		behavior.set_state_machine_trigger = _machine.set_trigger
		behavior.get_state_machine_property = get_property


func state_transition(old, new) -> void:

	if Engine.is_editor_hint():
		return

	var old_index = _behaviors.find_custom(func(b: BehaviorState): return b.name == old)
	var new_index = _behaviors.find_custom(func(b: BehaviorState): return b.name == new)
	assert(old_index > -1, 'state machine does not have behavior state named \'{0}\''.format({'0': old}))
	assert(new_index > -1, 'state machine does not have behavior state named \'{0}\''.format({'0': new}))

	var old_state = _behaviors[old_index]
	old_state.exit_state()
	old_state.state_active = false

	_active_state = _behaviors[new_index]
	_active_state.enter_state()
	_active_state.state_active = true


func set_property(property_name: String, value: Variant) -> void:

	if Engine.is_editor_hint():
		return

	if property_name == '' or property_name == null:
		printerr('state machine handler: invalid property name')
		return
	_machine.set_param(property_name, value)


func get_property(property_name: String) -> Variant:
	if Engine.is_editor_hint():
		return
	if property_name == '' or property_name == null:
		printerr('state machine handler: invalid property name')
		return
	return _machine.get_param(property_name)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _active_state != null:
		_active_state.tick_state(delta)


func set_shared_variable(variable_name: String, value: Variant) -> void:
	if Engine.is_editor_hint():
		return
	if variable_name == '' or variable_name == null:
		printerr('state machine handler: invalid variable name')
		return
	_state_machine_variables[variable_name] = value


func get_shared_variable(variable_name: String) -> Variant:
	if Engine.is_editor_hint():
		return
	if not _state_machine_variables.has(variable_name):
		printerr('state machine handler: no variable with name \'{0}\''.format({'0': variable_name}))
		return null
	return _state_machine_variables[variable_name]



func _on_player_internal_pull_release(extra_arg_0:String, extra_arg_1:bool) -> void:
	pass # Replace with function body.

