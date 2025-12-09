extends Node

signal high_score_updated(new_hi: int)

#@export var _records_file_uid: String
@export var _player_stats: Node
var _hot_records: Records
@export_file var _records_path: String

func _ready() -> void:
	#_records_path = ResourceUID.uid_to_path(_records_file_uid)
	_hot_records = load(_records_path)
	GameConstants.high_score = _hot_records.highest_score


func _on_game_end() -> void:

	var score = _player_stats.score
	_hot_records.add_record(score)

	if _hot_records.last_record_is_highest():
		high_score_updated.emit(score)

	ResourceSaver.save(_hot_records, _records_path)


func get_high_score() -> int:
	return _hot_records.highest_score
