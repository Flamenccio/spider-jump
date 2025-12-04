class_name InputServer
extends Node

## Emitted when the player presses the crawl buttons
## (A and D keys by default). Passes a [code]Vector2[/code]
## that corresponds to the direction the spider should crawl in,
## relative to the spider.
signal move_input_updated(move_input: Vector2)

## Emitted when the player changes the angle of the jump while aiming.
## Only emitted while the pull button is pressed down. Passes a
## [code]Vector2[/code] that corresponds to the angle of the pull.
signal pull_input_updated(pull_input: Vector2)

## Emitted when the player presses the pull button.
signal pull_released()

## Emitted when the player releases the pull button.
signal pull_pressed()

## Emitted when the player presses the pause button
signal pause_button_pressed()

# When using KBM pull, the maximum distance from the
# pull origin (player) that results in the highest
# launch power when released from this distance.
const _MAX_PULL_DISTANCE = 32.0

## When using KBM, the maximum distance from the
## pull origin when using the hoverfly powerup.
const _MAX_PULL_DISTANCE_HOVERFLY = 48.0

var pull_origin: Node2D
var _is_local := false
var _current_move_input := Vector2.ZERO 
var _current_max_pull_distance := _MAX_PULL_DISTANCE

func _ready() -> void:
	if self == GlobalInputServer:
		_setup_global()
	else:
		if not GlobalInputServer.is_node_ready():
			GlobalInputServer.ready.connect(_setup_local, ConnectFlags.CONNECT_ONE_SHOT)
		else:
			_setup_local()


func _setup_global() -> void:
	PlayerEventBus.powerup_started.connect(_on_powerup_started)
	PlayerEventBus.powerup_ended.connect(_on_powerup_ended)


func _setup_local() -> void:
	_is_local = true
	var global = GlobalInputServer
	global.move_input_updated.connect(func(x): move_input_updated.emit(x))
	global.pull_input_updated.connect(func(x): pull_input_updated.emit(x))
	global.pull_pressed.connect(func(): pull_pressed.emit())
	global.pull_released.connect(func(): pull_released.emit())
	global.pause_button_pressed.connect(func(): pause_button_pressed.emit())


func _on_powerup_started(powerup: String) -> void:
	match powerup:
		ItemIds.HOVERFLY_POWERUP:
			_current_max_pull_distance = _MAX_PULL_DISTANCE_HOVERFLY
		_:
			return


func _on_powerup_ended(powerup: String) -> void:
	match powerup:
		ItemIds.HOVERFLY_POWERUP:
			_current_max_pull_distance = _MAX_PULL_DISTANCE
		_:
			return


func _input(event: InputEvent) -> void:
	if _is_local:
		return
	_handle_move_input()
	_handle_pull_trigger(event)
	_handle_pause_button(event)


func _process(_delta: float) -> void:
	_handle_pull_input()


func _handle_move_input() -> void:
	var temp_input := Input.get_vector('move_left', 'move_right', 'move_up', 'move_down')
	if _current_move_input != temp_input:
		move_input_updated.emit(temp_input)
		_current_move_input = temp_input


func _handle_pull_input() -> void:

	if not Input.is_action_pressed("pull_button"):
		return

	if pull_origin == null:
		return

	var global_mouse_position := pull_origin.get_global_mouse_position()
	var raw_pull := global_mouse_position - pull_origin.global_position
	var normalized_pull := raw_pull.normalized()
	var magnitude := clampf(raw_pull.length(), 0.0, _current_max_pull_distance)
	magnitude = magnitude / _current_max_pull_distance
	
	var final := normalized_pull * magnitude

	pull_input_updated.emit(final)


func _handle_pull_trigger(event: InputEvent) -> void:
	if event.is_action_released('pull_button'):
		pull_released.emit()
	if event.is_action_pressed("pull_button"):
		pull_pressed.emit()


func _handle_pause_button(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_button_pressed.emit()
