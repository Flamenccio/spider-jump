extends Control

signal death_screen_button_pressed(button: String)

@onready var _score_display := %ScoreDisplay
@onready var _high_score_display := %HighScoreDisplay

func _ready() -> void:
	PlayerEventBus.player_stat_updated.connect(_on_player_stat_updated, ConnectFlags.CONNECT_DEFERRED)
	$Scores/HighScore/ScoreLabel.set_shader_param("osciallate_active", false)
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if visible:
		get_tree().call_group("centerer", "center_parent")


func _on_player_stat_updated(stat: String, value: Variant) -> void:
	if stat == PlayerStatsInterface.STATS_SCORE:
		_update_score(value as int)


func _update_score(score: int) -> void:
	_score_display.display_value(score)


func _update_high_score(score: int) -> void:
	_high_score_display.display_value(score)


func _new_high_score_reached() -> void:
	$Scores/HighScore/ScoreLabel.set_shader_param("osciallate_active", true)


func _on_button_pressed(button: String) -> void:
	death_screen_button_pressed.emit(button)

