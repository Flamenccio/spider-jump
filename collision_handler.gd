extends Node

signal set_state_machine_condition(condition: String, value)


func _on_ground_detector_body_exited(body:Node2D) -> void:
	set_state_machine_condition.emit('ground', false)


func _on_ground_detector_body_entered(body:Node2D) -> void:
	set_state_machine_condition.emit('ground', true)


func _on_slip_detector_body_exited(body:Node2D) -> void:
	set_state_machine_condition.emit('slippery', false)


func _on_slip_detector_body_entered(body:Node2D) -> void:
	set_state_machine_condition.emit('slippery', true)
