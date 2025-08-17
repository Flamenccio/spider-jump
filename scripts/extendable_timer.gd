class_name ExtendableTimer
## Like the `Timer` class, but the user can change its `time_left` while running.
extends Node

signal timeout()

var autostart: bool = false
var one_shot: bool = false
var paused: bool = false
var wait_time: float = 1.0
var time_left: float = 0.0

func _enter_tree() -> void:
	if autostart:
		start()


func _physics_process(delta: float) -> void:
	if paused:
		return
	if time_left <= 0.0:
		timeout.emit()
		if one_shot:
			paused = true
		else:
			time_left = wait_time
	
	time_left -= delta


func start(time: float = -1.0) -> void:
	if time > 0:
		wait_time = time
	time_left = wait_time
	paused = false


func stop() -> void:
	time_left = wait_time
	paused = true


func pause() -> void:
	paused = true


func change_time_left(change: float) -> void:
	time_left = clampf(time_left + change, 0.0, wait_time)

