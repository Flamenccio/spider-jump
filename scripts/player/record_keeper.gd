extends Node

const _RECORDS_SAVE_PATH = "user://scores.res"

signal new_high_score_reached()

var _hot_records: Records

@export var _player_stats: Node

func _ready() -> void:

	if not ResourceLoader.exists(_RECORDS_SAVE_PATH):
		_hot_records = Records.new()
		ResourceSaver.save(_hot_records, _RECORDS_SAVE_PATH)
	else:
		_hot_records = ResourceLoader.load(_RECORDS_SAVE_PATH)

	GameConstants.high_score = _hot_records.highest_score


func _on_game_end() -> void:

	var score = _player_stats.score
	if score > _hot_records.highest_score:
		GameConstants.high_score = score
		new_high_score_reached.emit()

	_hot_records.add_record(score)
	ResourceSaver.save(_hot_records, _RECORDS_SAVE_PATH)


func get_high_score() -> int:
	return _hot_records.highest_score
