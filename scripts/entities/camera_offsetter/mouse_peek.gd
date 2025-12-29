extends CameraOffsetter

## Player must be this far below the camera to
## enable mouse peeking
const _PLAYER_ENABLE_DISTANCE = 48.0

## Mouse must be at this normalized screen height to
## enable mouse peeking
const _MOUSE_ENABLE_HEIGHT = 0.8

const _MOUSE_PEEK_DISTANCE = 24.0
const _PEEK_LERP_WEIGHT = 0.02

var _pulling := false

func _ready() -> void:
	GlobalInputServer.pull_pressed.connect(_on_pull_pressed)
	GlobalInputServer.pull_released.connect(_on_pull_released)


func _process(_delta: float) -> void:

	if not _pulling:
		_sub_offset = _sub_offset.lerp(Vector2.ZERO, _PEEK_LERP_WEIGHT)
		return

	var player_vertical_distance = follow_target.global_position.y - camera.global_position.y
	var is_player_low = player_vertical_distance >= _PLAYER_ENABLE_DISTANCE

	var normalized_mouse_screen_position = camera.get_viewport().get_mouse_position() / camera.get_viewport_rect().size
	var is_mouse_low = normalized_mouse_screen_position.y >= _MOUSE_ENABLE_HEIGHT

	if is_player_low and is_mouse_low:
		_sub_offset = Vector2(0.0, lerpf(_sub_offset.y, _MOUSE_PEEK_DISTANCE, _PEEK_LERP_WEIGHT)) 


func _on_pull_pressed() -> void:
	_pulling = true


func _on_pull_released() -> void:
	_pulling = false