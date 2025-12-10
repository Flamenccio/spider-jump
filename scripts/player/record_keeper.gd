extends Node

signal new_high_score_reached()

var _hot_records: Records

@export var _player_stats: Node
@export_file var _records_path: String

func _ready() -> void:
	_hot_records = load(_records_path)
	GameConstants.high_score = _hot_records.highest_score


func _on_game_end() -> void:

	var score = _player_stats.score
	if score > _hot_records.highest_score:
		GameConstants.high_score = score
		new_high_score_reached.emit()

	_hot_records.add_record(score)
	ResourceSaver.save(_hot_records, _records_path)


func get_high_score() -> int:
	return _hot_records.highest_score
