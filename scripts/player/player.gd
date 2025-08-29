extends CharacterBody2D

# Internal use
signal internal_move_input_change(move_input: Vector2)
signal internal_pull_input_change(pull_input: Vector2)
signal internal_pull_release()
signal internal_pull_press()
signal internal_safe_spot_updated(in_screen: bool)
signal internal_player_fell(here: Vector2)

# External use
signal external_danger_entered()
signal external_set_safe_spot(here: Vector2)

# Any
signal stop_moving()
signal moving()

signal invincibility_started()
signal invincibility_ended()

# Used for invincibility after getting hurt
var _invincibility_timer: Timer = Timer.new()

# In seconds
const _DEFAULT_INVINCIBILITY_TIME = 6.0

func _ready() -> void:
	_invincibility_timer.one_shot = true
	_invincibility_timer.timeout.connect(func():
		invincibility_ended.emit()
	)
	add_child(_invincibility_timer)


func _on_input_service_move_input_change(move_input: Vector2) -> void:
	internal_move_input_change.emit(move_input)

	if move_input.x == 0:
		stop_moving.emit()
	else:
		moving.emit()


func _on_input_service_pull_input_change(pull_input: Vector2) -> void:
	internal_pull_input_change.emit(pull_input)


func _on_input_service_pull_release() -> void:
	internal_pull_release.emit()


func _on_input_service_pull_press() -> void:
	internal_pull_press.emit()


func _rotate_against_normal(normal: Vector2) -> void:
	# The player UP vector must match the given normal
	var up_angle := rotation - PI / 2.0
	var up_vector := Vector2.from_angle(up_angle)
	var difference := up_vector.angle_to(normal)
	rotation += difference


func _on_danger_entered() -> void:
	external_danger_entered.emit()


func _on_player_fell(here: Vector2) -> void:
	_start_invincibility()
	internal_player_fell.emit(here)


func _on_safe_spot_updated(on_screen: bool) -> void:
	internal_safe_spot_updated.emit(on_screen)


func _on_safe_spot_set(pos: Vector2) -> void:
	external_set_safe_spot.emit(pos)


func _start_invincibility(time: float = _DEFAULT_INVINCIBILITY_TIME) -> void:
	_invincibility_timer.stop()
	_invincibility_timer.start(time)
	invincibility_started.emit()
	
