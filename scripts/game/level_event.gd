class_name LevelEvent
extends Node

signal event_finished()

## How many points the player must gain for the event to end
@export var height_duration: int = 100
@export var event_id: String
var score_achieved: int = 0

# Score when event first activated
var base_score: int = -1

var active: bool:
	get:
		return _activated
	set(value):
		return

var _activated: bool = false

## Starts the level event. Once started, cannot be stopped.
func start_event() -> void:
	return


func end_event() -> void:
	return


func on_score_updated(new_score: int) -> void:

	new_score = abs(new_score)

	if not _activated:
		return

	# Don't call if this was already called with the same new_score
	if new_score == base_score + score_achieved:
		return

	if base_score < 0:
		base_score = new_score
	score_achieved = maxi(score_achieved, new_score - base_score)

	if score_achieved >= height_duration:
		event_finished.emit()
		end_event()

