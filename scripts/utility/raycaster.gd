class_name Raycaster
extends Node

## Used to retrieve the direct space state
@export var raycast_source: Node2D

func _ready() -> void:
	if raycast_source == null:
		push_error('raycaster: raycast_source is null')


func intersect_ray(query: PhysicsRayQueryParameters2D) -> Dictionary:
	var space_state = raycast_source.get_world_2d().direct_space_state
	return space_state.intersect_ray(query)
