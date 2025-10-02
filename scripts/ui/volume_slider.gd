@tool
class_name VolumeSlider
extends Control

signal volume_percent_updated(volume: float)
signal volume_bus_name_updated(bus_name: String)
signal volume_display_percent_updated(volume: String)
signal set_volume_slider(percent: float)

var _volume_bus_name: String

@export var volume_bus_name: String:
	set(value):
		_volume_bus_name = value
		volume_bus_name_updated.emit(value)
	get:
		return _volume_bus_name

func set_volume_percent(percent: float) -> void:
	set_volume_slider.emit(percent)


func _on_volume_value_updated(volume: float) -> void:
	if Engine.is_editor_hint():
		return
	volume_percent_updated.emit(volume)
	var display_value = "{0}%".format({"0": int(roundf(volume))})
	volume_display_percent_updated.emit(display_value)