class_name SoundManagerInterface
extends Node
## Allows nodes in a scene to communicate to the global sound manager,
## mostly via signals.

var _global_sound_manager := GlobalSoundManager

func play_sound(sound_id: String, bus: String = &"Master") -> void:
	_global_sound_manager.play_sound(sound_id, bus)
