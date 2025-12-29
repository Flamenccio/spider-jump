extends Node2D

const _POWERUP_META = "associated_powerup"

var _active_effect: CPUParticles2D
var _dust_effects := {}

func _ready() -> void:
	for c in get_children():
		if c.has_meta(_POWERUP_META) and c is CPUParticles2D:
			_dust_effects[c.get_meta(_POWERUP_META)] = c as CPUParticles2D


func play_dust() -> void:

	stop_dust()
	var current_powerup = GameConstants.current_powerup

	if _dust_effects.keys().has(current_powerup):
		_active_effect = _dust_effects[current_powerup]
	else:
		_active_effect = _dust_effects[ItemIds.NO_POWERUP]

	_active_effect.emitting = true


func stop_dust() -> void:
	if _active_effect != null:
		_active_effect.emitting = false
		_active_effect = null

