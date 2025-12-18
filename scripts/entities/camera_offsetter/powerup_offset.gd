extends CameraOffsetter

const _DEFAULT_POWERUP_HEIGHT = -32.0

## Time in seconds it takes to complete offset
const _OFFSET_ENABLE_DURATION = 0.3

## Time in seconds it takes to return offset to (0,0)
const _OFFSET_DISABLE_DURATION = 3.3

func _ready() -> void:
	PlayerEventBus.powerup_started.connect(_on_powerup_started)
	PlayerEventBus.powerup_ended.connect(_on_powerup_ended)


func _move_offset(to: Vector2, duration: float) -> void:
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
		_:
			return


func _on_powerup_ended(_powerup: String) -> void:
	_move_offset(Vector2.ZERO, _OFFSET_DISABLE_DURATION)