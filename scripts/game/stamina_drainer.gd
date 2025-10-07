extends Node

signal stamina_drained(amount: float)

# At level 0, stamina will drain 3.3% per second
const _BASE_STAMINA_DRAIN = 0.033

# When levelling up from level 0, stamina drain will increase by 0.5%
const _BASE_STAMINA_DRAIN_INCREASE = 0.003

const _STAMINA_DRAIN_INCREASE_MULTIPLIER = 0.25

const _SUPER_GRUB_PRIORITY = 5

# Current stamina drain
var _stamina_drain := _BASE_STAMINA_DRAIN

var _drain_paused := false
var _pause_priority := 0

func _ready() -> void:

	# Pause the stamina drain when playing the powerup animation
	PlayerEventBus.powerup_flash_start.connect(pause_drain)
	PlayerEventBus.powerup_flash_end.connect(resume_drain)

	# Super grub prevents stamina drain completely
	PlayerEventBus.powerup_started.connect(func(powerup: String):
		if powerup == ItemIds.SUPER_GRUB_POWERUP:
			pause_drain(_SUPER_GRUB_PRIORITY)
	)
	PlayerEventBus.powerup_ended.connect(func(powerup: String):
		if powerup == ItemIds.SUPER_GRUB_POWERUP:
			resume_drain(_SUPER_GRUB_PRIORITY)
	)


func _process(delta: float) -> void:
	if _drain_paused:
		return
	stamina_drained.emit(delta * _stamina_drain * -1)


## Pause the player's stamina drain[br]
## - a `priority` can be optionally set to prevent lower-priority
## calls from unpausing the stamina drain.[br]
## - if `priority` is greater than or equal to the priority given on the last
## `pause_drain` call (or `0` either by default, or if drain was resumed), 
## sets the pause priority to `priority`.
func pause_drain(priority: int = 0) -> void:
	if _drain_paused or priority < _pause_priority:
		return
	_pause_priority = priority
	_drain_paused = true


## Unpause the player's stamina drain[br]
## - if `priority` is less than the priority given on the last
## `pause_drain` call, fails[br]
## - if successful, resets the pause priority to 0
func resume_drain(priority: int = 0) -> void:
	if not _drain_paused or priority < _pause_priority:
		return
	_pause_priority = 0
	_drain_paused = false


func _on_level_up(new_level: int) -> void:
	_stamina_drain += _get_stamina_drain_increase(new_level - 1)


func _get_stamina_drain_increase(level: int) -> float:
	return _BASE_STAMINA_DRAIN_INCREASE / (_STAMINA_DRAIN_INCREASE_MULTIPLIER * level + 1)