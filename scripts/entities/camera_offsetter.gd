class_name CameraOffsetter
extends Node

var follow_target: Node2D
var camera: Node2D

## Accepts a Vector2 and returns a Vector2
var screen_to_world_point: Callable

## Accepts a Vector2 and returns a Vector2
var world_to_screen_point: Callable

var _sub_offset: Vector2

## Get the offset value of this offsetter
func get_offset() -> Vector2:
	return _sub_offset


func _on_receive_message(msg: String, value: Variant) -> void:
	return
