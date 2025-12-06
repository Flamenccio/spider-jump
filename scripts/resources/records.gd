class_name Records
extends Resource

const _MAX_RECORDS = 10

@export var records: Array[GameRecord]
@export var highest_score: int

func add_record(score: int, name := "Player") -> void:

	var new_record = GameRecord.new()
	new_record.score = absi(score)
	new_record.player_name = name
	new_record.date = Time.get_datetime_dict_from_system(true)
	records.append(new_record)

	if absi(score) > highest_score:
		highest_score = absi(score)
	
	_sort_records()

	if records.size() > _MAX_RECORDS:
		records.remove_at(records.size() - 1)


func last_record_is_highest() -> bool:
	if records.size() == 0:
		return true
	var last_record = records[records.size() - 1]
	return last_record.score > highest_score


func _sort_records() -> void:
	records.sort_custom(func(a, b): return a.score > b.score)
