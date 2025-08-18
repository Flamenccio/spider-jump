@tool
extends Node
class_name StateMachineHandler

@export var _machine: Node
var _behavior_info: Array[BehaviorStateInfo]
var _active_state: BehaviorState

# Variables that behaviors can share with each other
var _state_machine_variables: Dictionary

class BehaviorStateInfo:
	var local_node_path: String = ''
	var state: BehaviorState


func _ready() -> void:

	if Engine.is_editor_hint():
		return

	var children = _get_children_recursive(self)
	assert(children.size() > 0, 'state machine handler must have behavior states as its children')

	# Parse into BehaviorStateInfo
	var path = get_path()
	for child in children:
		if child is not BehaviorState:
			continue
		var info = BehaviorStateInfo.new()
		# Get the path from the state machine handler node
		var child_path = child.get_path() as String
		child_path = child_path.replace('{0}/'.format({'0': path}), '')
		info.local_node_path = child_path
		#print('new state: ', child_path)
		info.state = child as BehaviorState
		_behavior_info.append(info)

	# Supply callables
	for b: BehaviorStateInfo in _behavior_info:
		var behavior = b.state
		behavior.set_state_machine_property = set_property
		behavior.set_shared_state_machine_variable = set_shared_variable
		behavior.get_shared_state_machine_variable = get_shared_variable
		behavior.set_state_machine_trigger = _machine.set_trigger
		behavior.get_state_machine_property = get_property


func _get_children_recursive(parent: Node) -> Array[Node]:
	var children = parent.get_children()
	for child: Node in children:
		children.append_array(_get_children_recursive(child))
	return children


func state_transition(old, new) -> void:

	if Engine.is_editor_hint():
		return

	var old_index = _behavior_info.find_custom(func(b: BehaviorStateInfo): return b.local_node_path == old)
	var new_index = _behavior_info.find_custom(func(b: BehaviorStateInfo): return b.local_node_path == new)
	assert(old_index > -1, 'state machine does not have behavior state named \'{0}\''.format({'0': old}))
	assert(new_index > -1, 'state machine does not have behavior state named \'{0}\''.format({'0': new}))

	var old_state = _behavior_info[old_index].state
	old_state.exit_state()
	old_state.state_active = false

	_active_state = _behavior_info[new_index].state
	_active_state.enter_state()
	_active_state.state_active = true

	#print('state machine: {0} -> {1}'.format({'0': old_state.name, '1': _active_state.name}))


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
