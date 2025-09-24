@tool
extends Item

signal chase_started()

const _BASE_VERTICAL_SPEED = 20.0
const _VERTICAL_SPEED_INCREASE = 5.0
const _WAVE_AMPLITUDE = 0.5
const _WAVE_FREQUENCY = 3.0

var _current_vertical_speed := _BASE_VERTICAL_SPEED
var _retreating := false
var _wave_progress := 0.0
var _entered_screen := false

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not _retreating:
		return
	var _vertical_change = _current_vertical_speed * delta * -1
	var _horizontal_change = _WAVE_AMPLITUDE * cos(_WAVE_FREQUENCY * _wave_progress)
	global_position += Vector2(_horizontal_change, _vertical_change)
	_wave_progress += delta


func _on_player_detected() -> void:
	if Engine.is_editor_hint():
		return
	chase_started.emit()
	_retreating = true


func _on_item_collected() -> void:
	if Engine.is_editor_hint():
		return
	_current_vertical_speed += _VERTICAL_SPEED_INCREASE


func _on_exited_screen() -> void:
	if Engine.is_editor_hint():
		return
	if not _entered_screen:
		return
	queue_free()


func _on_entered_screen() -> void:
	if Engine.is_editor_hint():
		return
	_entered_screen = true