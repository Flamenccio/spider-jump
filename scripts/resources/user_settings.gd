class_name UserSettings
extends Resource

## Audio levels range from 0.0 (silence) to 1.0 (maximum volume).
## Keys represent the audio bus, and the values represent their linear volume.
@export var audio_levels: Dictionary[String, float]

## If [code]true[/code], plays the tutorial every time the game starts from the
## main menu. Tutorials do not play after restarting from the pause or game over menu.
@export var repeat_tutorial := false

## [code]true[/code] if the tutorial has played at least once.
@export var tutorial_played := false
