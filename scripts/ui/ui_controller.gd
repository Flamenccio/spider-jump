extends Control

signal internal_score_updated(score: int)
signal internal_high_score_updated(score: int)
signal new_high_score_reached()

@export var _visible_on_ready: bool = true

func _ready() -> void:
	if _visible_on_ready:
		show()
	else:
		hide()
	PlayerEventBus.player_stat_updated.connect(func(stat: String, value):
		if stat == PlayerStatsInterface.STATS_SCORE:
			_update_score(value as int)
	, ConnectFlags.CONNECT_DEFERRED)


func _update_score(score: int) -> void:
	internal_score_updated.emit(score)


func _update_high_score(score: int) -> void:
	internal_high_score_updated.emit(score)


func _new_high_score_reached() -> void:
	new_high_score_reached.emit()
