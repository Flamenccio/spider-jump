class_name SettingsCheckbox
extends CheckBox

@export var _setting_name: String

func _ready() -> void:
	var s = SettingsService.get_settings().get(_setting_name, null)
	if s == null:
		return
	if typeof(s) != TYPE_BOOL:
		return
	button_pressed = s
	toggled.connect(_on_checkbox_toggled)


func _on_checkbox_toggled(on: bool) -> void:
	SettingsService.update_setting(_setting_name, on)
	SettingsService.write_settings()
