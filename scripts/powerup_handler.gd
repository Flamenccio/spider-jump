extends Node

signal powerup_started(powerup: String)
signal powerup_ended()

@export var _animator: SpriteTree

var current_powerup: String = ''
var _powerup_end_queue: Array[Callable]
var _powerup_timer: Timer = Timer.new()
var _powerup_flash_timer: Timer = Timer.new()

const _POWERUP_FLASH_DURATION = 0.333

func _ready() -> void:
	_powerup_timer.timeout.connect(_end_powerups)
	_powerup_timer.one_shot = true
	add_child(_powerup_timer)

	_powerup_flash_timer.timeout.connect(func(): PlayerEventBus.powerup_flash_end.emit())
	_powerup_flash_timer.one_shot = true
	_powerup_flash_timer.wait_time = _POWERUP_FLASH_DURATION
	add_child(_powerup_flash_timer)


func _on_powerup_consumed(powerup: String) -> void:
	_handle_powerup(powerup)


func _end_powerups() -> void:
	if current_powerup == 'none':
		return
	_powerup_timer.stop()
	powerup_ended.emit()
	_animator.switch_sprite_branch('normal')
	PlayerEventBus.powerup_ended.emit(current_powerup)
	while _powerup_end_queue.size() > 0:
		var p = _powerup_end_queue.pop_front() as Callable
		p.call()
	current_powerup = 'none'


func _handle_powerup(powerup: String) -> void:

	# End any existing powerup
	_end_powerups()
	powerup_started.emit(powerup)
	PlayerEventBus.powerup_started.emit(powerup)
	PlayerEventBus.powerup_flash_start.emit()
	_powerup_flash_timer.start()
	current_powerup = powerup

	match powerup:
		'hoverfly':
			_defer_powerup_timer(10)
			_animator.switch_and_play('hoverfly', 'hover')
		'antibug':
			_powerup_end_queue.push_back(func():
				GameConstants.current_gravity = GameConstants.DEFAULT_GRAVITY
			)
			_defer_powerup_timer(10)
			GameConstants.current_gravity = -GameConstants.DEFAULT_GRAVITY
			_animator.switch_sprite_branch('antibug')
		'super_grub':
			PlayerStatsInterface.change_stat.emit('stamina', 1.0)
			_defer_powerup_timer(20)
			_animator.switch_sprite_branch('supergrub')
		'bubblebee':
			_defer_powerup_timer(10)
			_animator.switch_sprite_branch('bubblebee')
			GameConstants.current_gravity = GameConstants.DEFAULT_GRAVITY / 2.0
			_powerup_end_queue.push_back(func():
				GameConstants.current_gravity = GameConstants.DEFAULT_GRAVITY
			)
		'hopperpop':
			_defer_powerup_timer(10)
			_animator.switch_sprite_branch('hopperpop')
		'heavy_beetle':
			_defer_powerup_timer(15)
			_animator.switch_sprite_branch('heavybeetle')
			GameConstants.current_gravity = GameConstants.DEFAULT_GRAVITY * 1.5
			_powerup_end_queue.push_back(func():
				GameConstants.current_gravity = GameConstants.DEFAULT_GRAVITY
			)
		_:
			printerr('powerup handler: unhandled powerup "{0}"'.format({'0': powerup}))
			return


func _process(delta: float) -> void:
	if current_powerup != '':
		PlayerEventBus.powerup_timer_updated.emit(_powerup_timer.time_left, _powerup_timer.wait_time)


## Start the powerup timer after the powerup flash ends
func _defer_powerup_timer(time: float) -> void:
	PlayerEventBus.powerup_flash_end.connect(func(): _powerup_timer.start(time), ConnectFlags.CONNECT_ONE_SHOT)

