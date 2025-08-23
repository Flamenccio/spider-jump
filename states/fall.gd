extends BehaviorState

@export var _animator: SpriteTree
@export var _player: CharacterBody2D
var motion: Vector2
var _current_powerup: String

func _ready() -> void:
	PlayerEventBus.powerup_started.connect(func(powerup: String):
		_current_powerup = powerup
	)
	PlayerEventBus.powerup_ended.connect(func(powerup: String):
		_current_powerup = ItemIds.NO_POWERUP
	)


func enter_state() -> void:
	if _current_powerup != ItemIds.BLINKFLY_POWERUP:
		_animator.play_branch_animation('fall')


func update_state(delta: float) -> void:
	_player.velocity += Vector2(0.0, GameConstants.current_gravity * delta)
	_player.move_and_slide()
