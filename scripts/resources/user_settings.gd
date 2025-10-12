class_name UserSettings
extends Resource

## Audio levels range from 0.0 (silence) to 1.0 (maximum volume).
## Keys represent the audio bus, and the values represent their linear volume.
@export var audio_levels: Dictionary[String, float]
