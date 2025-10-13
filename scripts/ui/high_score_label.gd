extends Label

const _HIGH_SCORE_PATH = "res://hi_scores/hiscore.res"

func _ready() -> void:
	_initialize_hiscore()


func _initialize_hiscore() -> void:
	var score := 0
	if not ResourceLoader.exists(_HIGH_SCORE_PATH):
		return
	var hiscore = load(_HIGH_SCORE_PATH)
	if hiscore is not SavedPlayerStats:
		return
	score = (hiscore as SavedPlayerStats).high_score
	var score_string = str(score).pad_zeros(6)
	var label_text = "{0}: {1}".format({"0": tr("ui.label.generic.high_score"), "1": score_string})
	text = label_text
