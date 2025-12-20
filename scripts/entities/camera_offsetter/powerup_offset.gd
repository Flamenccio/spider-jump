extends CameraOffsetter

const _DEFAULT_POWERUP_HEIGHT = -32.0

## Time in seconds it takes to complete offset
const _OFFSET_ENABLE_DURATION = 0.3

## Time in seconds it takes to return offset to (0,0)
const _OFFSET_DISABLE_DURATION = 3.3

## If player goes below this normalized screen height, offset goes down
const _DOWN_ADJUST_THRESHOLD = 0.9

var _target_height := 0.0

func _ready() -> void:
	PlayerEventBus.powerup_started.connect(_on_powerup_started)
	PlayerEventBus.powerup_ended.connect(_on_powerup_ended)


func _process(_delta: float) -> void:
	_adjust_powerup_height()


func _adjust_powerup_height() -> void:

	if _target_height >= 0.0:
		return

	var normalized_player_position = world_to_screen_point.call(follow_target.global_position) / camera.get_viewport_rect().size
	var normalized_height = normalized_player_position.y

	if normalized_height >= _DOWN_ADJUST_THRESHOLD:
		_sub_offset = _sub_offset.lerp(Vector2(0.0, 32.0), 0.03)
	elif _sub_offset.y > _target_height:
		_sub_offset = _sub_offset.lerp(Vector2(0.0, _target_height), 0.04)


func _move_offset(to: Vector2, duration: float) -> void:
	_target_height = to.y
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "_sub_offset", to, duration)


func _on_powerup_started(powerup: String) -> void:
	match powerup:
		ItemIds.HOVERFLY_POWERUP:
			_move_offset(Vector2(0.0, _DEFAULT_POWERUP_HEIGHT), _OFFSET_ENABLE_DURATION)
		ItemIds.HOPPERPOP_POWERUP:
			_move_offset(Vector2(0.0, _DEFAULT_POWERUP_HEIGHT), _OFFSET_ENABLE_DURATION)
		ItemIds.BLINKFLY_POWERUP:
			_move_offset(Vector2(0.0, _DEFAULT_POWERUP_HEIGHT), _OFFSET_ENABLE_DURATION)
		ItemIds.ANTIBUG_POWERUP:
			_move_offset(Vector2(0.0, _DEFAULT_POWERUP_HEIGHT), _OFFSET_ENABLE_DURATION)
		_:
			return


func _on_powerup_ended(_powerup: String) -> void:
	_move_offset(Vector2.ZERO, _OFFSET_DISABLE_DURATION)