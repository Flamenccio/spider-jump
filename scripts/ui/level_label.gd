extends Label

func _ready() -> void:
	update_level(0)


func update_level(level: int) -> void:
	var prefix = tr("ui.label.hud.level")
	text = "{0} {1}".format({"0": prefix, "1": level})