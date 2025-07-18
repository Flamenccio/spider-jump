extends Node
class_name BehaviorState

var set_state_machine_property: Callable
var get_state_machine_property: Callable
var set_shared_state_machine_variable: Callable
var get_shared_state_machine_variable: Callable
var set_state_machine_trigger: Callable
var state_active: bool = false

## Invoked when a state machine enters this state
func enter_state() -> void:
	pass


## Invoked when a state machine exits this state
func exit_state() -> void:
	pass


## Invoked every physics update when this state is active
func tick_state(delta: float) -> void:
	pass


## Sets a state machine property named `property` to `value`.
func set_property(property: String, value) -> void:
	set_state_machine_property.call(property, value)


func get_property(property: String) -> Variant:
	return get_state_machine_property.call(property)


func set_shared_variable(variable: String, value) -> void:
	set_shared_state_machine_variable.call(variable, value)


func get_shared_variable(variable: String) -> Variant:
	return get_shared_state_machine_variable.call(variable)


func set_trigger(trigger: String) -> void:
	set_state_machine_trigger.call(trigger)