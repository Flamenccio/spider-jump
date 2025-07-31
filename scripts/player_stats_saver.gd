extends Node

signal high_score_displayed(hi: int)
signal high_score_updated(new_hi: int)

@export var _directory: String
@export var _player_stats: Node
var save_directory: String

const _SCORE_FILENAME = 'hiscore.res'

func _ready() -> void:
	var test = DirAccess.open(_directory)
	if not test:
		printerr('player stats saver: invalid directory')
		return
	save_directory = "{0}/{1}".format({"0": _directory, "1": _SCORE_FILENAME})


func _on_game_end() -> void:

	var score = _player_stats.score
	var dir := DirAccess.open(_directory)
	var files = dir.get_files()

	if files.size() == 0 or not files.has(_SCORE_FILENAME):
		_save_new_file(score, save_directory)
		high_score_updated.emit(score)
		return

	var res = ResourceLoader.load(save_directory)
	if res is not SavedPlayerStats:
		_save_new_file(score, save_directory)
		high_score_updated.emit(score)
		return

	# Compare scores
	res = res as SavedPlayerStats
	var high_score = res.high_score
	var abs_score = abs(score)

	if abs_score > high_score:
		high_score_updated.emit(abs_score)
		res.high_score = abs_score
		ResourceSaver.save(res, save_directory)

	high_score_displayed.emit(res.high_score)


func _save_new_file(high_score: int, dir: String) -> void:
	var saved = SavedPlayerStats.new()
	saved.high_score = high_score
	ResourceSaver.save(saved, dir)


func get_high_score() -> int:
	var dir = DirAccess.open(_directory)
	if not dir.file_exists(save_directory):
		return 0
	var res = ResourceLoader.load(save_directory)
	if res is not SavedPlayerStats:
		return 0
	return (res as SavedPlayerStats).high_score

