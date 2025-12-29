extends Node

var _sound_manager := GlobalSoundManager
var _jumped := false

func play_jump() -> void:
	_jumped = true
	_sound_manager.play_sound("player/jump")


func play_hopperpop_jump() -> void:
	_jumped = true
	_sound_manager.play_sound("player/super_jump")


func play_antibug_jump() -> void:
	_jumped = true
	_sound_manager.play_sound("player/reverse_jump")


func play_bubblebee_jump() -> void:
	_jumped = true
	_sound_manager.play_sound("player/bubble_jump")


func play_blinkfly_jump() -> void:
	_jumped = true
	_sound_manager.play_sound("player/blinkfly_jump")


func play_land() -> void:
	if not _jumped: return
	_jumped = false
	_sound_manager.play_sound("player/land")


func play_hurt() -> void:
	_sound_manager.play_sound("player/hurt")


func play_lose_powerup() -> void:
	_sound_manager.play_sound("player/lose_powerup")


func play_gain_powerup() -> void:
	match GameConstants.current_powerup:
		ItemIds.HOPPERPOP_POWERUP:
			_sound_manager.play_sound("player/gain_powerup_hopperpop")
		ItemIds.BUBBLEBEE_POWERUP:
			_sound_manager.play_sound("player/gain_powerup_bubblebee")
		ItemIds.HOVERFLY_POWERUP:
			_sound_manager.play_sound("player/gain_powerup_hoverfly")
		ItemIds.HEAVY_BEETLE_POWERUP:
			_sound_manager.play_sound("player/gain_powerup_heavy_beetle")
		ItemIds.BLINKFLY_POWERUP:
			_sound_manager.play_sound("player/gain_powerup_blinkfly")
		ItemIds.ANTIBUG_POWERUP:
			_sound_manager.play_sound("player/gain_powerup_antibug")
		_:
			_sound_manager.play_sound("player/gain_powerup")


func play_collect_item() -> void:
	_sound_manager.play_sound("ui/select")
