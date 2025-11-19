class_name SoundManagerInterface
extends Node
## Allows nodes in a scene to communicate to the global sound manager,
## mostly via signals.

func play_sound(sound_id: String, _bus: String = &"Master") -> void:
	GlobalSoundManager.play_sound(sound_id)
