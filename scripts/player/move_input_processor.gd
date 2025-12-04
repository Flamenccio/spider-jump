extends Node

signal move_input_processed(input: Vector2)

var _move_input: Vector2
var _camera_based_crawl := false
var _player: CharacterBody2D

func _ready() -> void:
	_player = get_parent()
	SettingsService.settings_updated.connect(_on_settings_updated)
	_camera_based_crawl = SettingsService.get_settings().get("camera_based_crawl")


func _on_settings_updated(settings_name: String, setting_value: Variant) -> void:
	if settings_name == "camera_based_crawl":
		_camera_based_crawl = setting_value


func _on_move_input_updated(move: Vector2) -> void:

	_move_input = move

	if _camera_based_crawl:

		var player_right = Vector2.RIGHT.rotated(_player.rotation)
		var player_left = Vector2.LEFT.rotated(_player.rotation)
		var right_dot = snappedf(player_right.dot(move), 0.001)
		var left_dot = snappedf(player_left.dot(move), 0.001)

		if right_dot == 0.0 and left_dot == 0.0:
			move_input_processed.emit(Vector2.ZERO)
			return

		if right_dot > left_dot:
			move_input_processed.emit(Vector2.RIGHT)
		else:
			move_input_processed.emit(Vector2.LEFT)

	else:
		move_input_processed.emit(move - Vector2(0.0, move.y))


func force_update() -> void:
	_on_move_input_updated(_move_input)
