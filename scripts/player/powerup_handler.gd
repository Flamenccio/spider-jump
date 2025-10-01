extends Node

signal on_powerup_started()
signal powerup_started(powerup: String)
signal powerup_ended()

const _POWERUP_FLASH_DURATION = 0.333
const _HOVERFLY_DURATION = 10.0
const _ANTIBUG_DURATION = 10.0
const _SUPER_GRUB_DURATION = 20.0
const _BUBBLEBEE_DURATION = 10.0
const _HOPPERPOP_DURATION = 10.0
const _HEAVY_BEETLE_DURATION = 30.0
const _BLINKFLY_USES = 8

# Every time the player contacts a dangerous item under the
# heavy beetle powerup, deduct this amount of time from the
# powerup duration.
const _HEAVY_BEETLE_HURT_TIME_REDUCTION = 2.0

var current_powerup: String = ''
var _powerup_end_queue: Array[Callable]
var _powerup_timer: ExtendableTimer = ExtendableTimer.new()
var _powerup_flash_timer: Timer = Timer.new()
var _blinkfly_jumped := false

@export var _animator: SpriteTree


func _ready() -> void:

	_powerup_timer.timeout.connect(_end_powerups)
	_powerup_timer.one_shot = true
	add_child(_powerup_timer)

	_powerup_flash_timer.timeout.connect(func(): PlayerEventBus.powerup_flash_end.emit())
	_powerup_flash_timer.one_shot = true
	_powerup_flash_timer.wait_time = _POWERUP_FLASH_DURATION
	add_child(_powerup_flash_timer)

	PlayerEventBus.item_collected.connect(_on_item_collected)


func _process(_delta: float) -> void:
	if current_powerup != '':
		PlayerEventBus.powerup_timer_updated.emit(_powerup_timer.time_left, _powerup_timer.wait_time)


func _end_powerups() -> void:
	if current_powerup == ItemIds.NO_POWERUP or current_powerup == "":
		return
	_powerup_timer.stop()
	powerup_ended.emit()
	_animator.switch_sprite_branch('normal')
	PlayerEventBus.powerup_ended.emit(current_powerup)
	GameConstants.current_powerup = ItemIds.NO_POWERUP
	while _powerup_end_queue.size() > 0:
		var p = _powerup_end_queue.pop_front() as Callable
		p.call()
	current_powerup = ItemIds.NO_POWERUP
	GlobalFlashParticleSpawner.spawn_particle("powerup_loss_flash", GameConstants.player.global_position, 0.0)


func _handle_powerup(powerup: String) -> void:

	# End any existing powerup
	_end_powerups()
	powerup_started.emit(powerup)
	on_powerup_started.emit()
	PlayerEventBus.powerup_started.emit(powerup)
	PlayerEventBus.powerup_flash_start.emit()
	_powerup_flash_timer.start()
	GameConstants.current_powerup = powerup
	current_powerup = powerup

	match powerup:
		ItemIds.HOVERFLY_POWERUP:
			_defer_powerup_timer(_HOVERFLY_DURATION)
			_animator.switch_and_play(ItemIds.HOVERFLY_POWERUP, 'hover')
		ItemIds.ANTIBUG_POWERUP:
			_powerup_end_queue.push_back(func():
				GameConstants.current_gravity = GameConstants.DEFAULT_GRAVITY
			)
			_defer_powerup_timer(_ANTIBUG_DURATION)
			GameConstants.current_gravity = -GameConstants.DEFAULT_GRAVITY
			_animator.switch_sprite_branch(ItemIds.ANTIBUG_POWERUP)
		ItemIds.SUPER_GRUB_POWERUP:
			PlayerStatsInterface.change_stat.emit(PlayerStatsInterface.STATS_STAMINA, 1.0)
			_defer_powerup_timer(_SUPER_GRUB_DURATION)
			_animator.switch_sprite_branch(ItemIds.SUPER_GRUB_POWERUP)
		ItemIds.BUBBLEBEE_POWERUP:
			_defer_powerup_timer(_BUBBLEBEE_DURATION)
			_animator.switch_sprite_branch(ItemIds.BUBBLEBEE_POWERUP)
			GameConstants.current_gravity = GameConstants.DEFAULT_GRAVITY / 2.0
			_powerup_end_queue.push_back(func():
				GameConstants.current_gravity = GameConstants.DEFAULT_GRAVITY
			)
		ItemIds.HOPPERPOP_POWERUP:
			_defer_powerup_timer(_HOPPERPOP_DURATION)
			_animator.switch_sprite_branch(ItemIds.HOPPERPOP_POWERUP)
		ItemIds.HEAVY_BEETLE_POWERUP:
			_defer_powerup_timer(_HEAVY_BEETLE_DURATION)
			_animator.switch_sprite_branch(ItemIds.HEAVY_BEETLE_POWERUP)
			GameConstants.current_gravity = GameConstants.DEFAULT_GRAVITY * 1.5
			_powerup_end_queue.push_back(func():
				GameConstants.current_gravity = GameConstants.DEFAULT_GRAVITY
			)
		ItemIds.BLINKFLY_POWERUP:
			_powerup_timer.wait_time = _BLINKFLY_USES
			_powerup_timer.time_left = _BLINKFLY_USES
			_animator.switch_sprite_branch(ItemIds.BLINKFLY_POWERUP)
		_:
			printerr('powerup handler: unhandled powerup "{0}"'.format({'0': powerup}))
			return


## Start the powerup timer after the powerup flash ends
func _defer_powerup_timer(time: float) -> void:
	PlayerEventBus.powerup_flash_end.connect(func(): _powerup_timer.start(time), ConnectFlags.CONNECT_ONE_SHOT)


func _on_item_collected(item: String) -> void:
	if current_powerup == ItemIds.SUPER_GRUB_POWERUP:
		if item == ItemIds.YUMFLY_ITEM:
			# Add more time to the powerup timer
			_powerup_timer.change_time_left(1.0)


func _on_player_landed() -> void:
	if _blinkfly_jumped:
		_blinkfly_jumped = false
		_powerup_timer.change_time_left(-1.0)
		if _powerup_timer.time_left <= 0.0:
			_end_powerups()


func _on_player_blinkfly_jumped() -> void:
	_blinkfly_jumped = true


func _on_player_hurt() -> void:
	if current_powerup == ItemIds.HEAVY_BEETLE_POWERUP:
		GlobalFlashParticleSpawner.spawn_particle("heavy_beetle_deflect", GameConstants.player.global_position, 0.0)
		_powerup_timer.change_time_left(-_HEAVY_BEETLE_HURT_TIME_REDUCTION)