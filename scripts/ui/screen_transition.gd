extends TextureRect

enum TransitionDirection {
	## Transitions move upward [br]
	## - Enter from bottom [br]
	## - Exit to top
	UP,

	## Transitions move to the right [br]
	## - Enter from left [br]
	## - Exit to right
	RIGHT,

	## Transitions move downward [br]
	## - Enter from top [br]
	## - Exit to bottom
	DOWN,

	## Transitions move to the left [br]
	## - Enter from right [br]
	## - Exit to left
	LEFT,
}

const _MIN_TRANSITION_SPEED = 1.0
const _MAX_TRANSITION_SPEED = 100.0

var _animation_active := false
var _animation_action: Callable
var _animation_timer: Timer = Timer.new()

@export_range(_MIN_TRANSITION_SPEED, _MAX_TRANSITION_SPEED) var _animation_speed: float
@export var _enter_animation := TransitionDirection.UP
@export var _exit_animation := TransitionDirection.UP

func _ready() -> void:
	_animation_timer.autostart = false
	_animation_timer.one_shot = true
	_animation_timer.timeout.connect(_stop_animation)
	add_child(_animation_timer)


func play_enter_animation() -> void:

	if not _assert_animation():
		return

	_play_enter_animation(_enter_animation)


func play_exit_animation() -> void:

	if not _assert_animation():
		return

	_play_exit_animation(_exit_animation)


func _assert_animation() -> bool:

	if _animation_active:
		return false
	
	_animation_active = true
	return true


func _play_enter_animation(transition_direction: TransitionDirection) -> void:
	match transition_direction:
		TransitionDirection.UP:
			pass
		TransitionDirection.RIGHT:
			pass
		TransitionDirection.DOWN:
			pass
		TransitionDirection.LEFT:
			pass


func _play_exit_animation(transition_direction: TransitionDirection) -> void:
	match transition_direction:
		TransitionDirection.UP:
			pass
		TransitionDirection.RIGHT:
			pass
		TransitionDirection.DOWN:
			pass
		TransitionDirection.LEFT:
			pass


func _build_animation_callable(is_enter: bool, transition_direction: TransitionDirection) -> Callable:
	var direction_multiplier = 1.0 if is_enter else -1.0
	var travel_vector = _get_travel_vector(transition_direction)
	var speed = _animation_speed
	return func(delta: float) -> void:
		global_position += travel_vector * speed * delta * direction_multiplier


func _get_travel_vector(transition_direction: TransitionDirection) -> Vector2:

	match transition_direction:
		TransitionDirection.UP:
			return Vector2.UP
		TransitionDirection.RIGHT:
			return Vector2.RIGHT
		TransitionDirection.DOWN:
			return Vector2.DOWN
		TransitionDirection.LEFT:
			return Vector2.LEFT
		_:
			return Vector2.ZERO


func _stop_animation() -> void:
	global_position = Vector2.ZERO
	_animation_active = false
	_animation_action = func(): return