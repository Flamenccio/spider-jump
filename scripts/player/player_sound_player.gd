extends Node

var _sound_manager := GlobalSoundManager
var _jumped := false

func play_jump() -> void:
	_jumped = true
	_sound_manager.play_sound("player/jump", "SFX")


func play_hopperpop_jump() -> void:
	_jumped = true
	_sound_manager.play_sound("player/super_jump", "SFX")


func play_antibug_jump() -> void:
	_jumped = true
	_sound_manager.play_sound("player/reverse_jump", "SFX")


func play_bubblebee_jump() -> void:
	_jumped = true
	_sound_manager.play_sound("player/bubble_jump", "SFX")


func play_blinkfly_jump() -> void:
	_jumped = true
	_sound_manager.play_sound("player/blinkfly_jump", "SFX")


func play_land() -> void:
	if not _jumped: return
	_jumped = false
	_sound_manager.play_sound("player/land", "SFX")


func play_hurt() -> void:
	_sound_manager.play_sound("player/hurt", "SFX")


func play_lose_powerup() -> void:
	_sound_manager.play_sound("player/lose_powerup", "SFX")


func play_gain_powerup() -> void:
	_sound_manager.play_sound("player/gain_powerup", "SFX")