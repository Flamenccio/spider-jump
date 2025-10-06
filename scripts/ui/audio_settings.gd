extends UIScreen

## 0% on volume slider
const _MIN_VOLUME_DB = -80

## 100% on volume slider
const _MAX_VOLUME_DB = 0

func _ready() -> void:

	var children = get_children()
	var volume_sliders: Array[VolumeSlider]
	for c in children:
		if c is VolumeSlider:
			volume_sliders.append(c as VolumeSlider)

	var audio_buses = AudioServer.bus_count

	for i in range(audio_buses):
		# Set volume slider value to corresponding audio bus volume
		if not _reset_volume_slider(i, volume_sliders):
			continue
		# Attach listeners to sliders to adjust audio bus volume when values update
		_attach_slider_listener(i, volume_sliders)


func _reset_volume_slider(bus_index: int, volume_sliders: Array[VolumeSlider]) -> bool:
	
	var current_volume := AudioServer.get_bus_volume_db(bus_index)
	var current_bus_name := AudioServer.get_bus_name(bus_index)
	var slider_index := volume_sliders.find_custom(func(v: VolumeSlider): return v.volume_bus_name == current_bus_name)

	if slider_index < 0:
		return false

	var slider := volume_sliders[slider_index]
	var percent = _get_volume_percent(current_volume)
	slider.set_volume_percent(percent * 100.0)
	return true


func _get_volume_percent(volume_db: float) -> float:
	var a = (1.0 - 0.0) / (_MAX_VOLUME_DB - _MIN_VOLUME_DB)
	var b = 1 - a * _MAX_VOLUME_DB
	return a * volume_db + b


func _get_volume_db(volume_percent: float) -> float:
	var a = (1.0 - 0.0) / (_MAX_VOLUME_DB - _MIN_VOLUME_DB)
	var b = 1 - a * _MAX_VOLUME_DB
	return (volume_percent - b) / a


func _attach_slider_listener(bus_index: int, volume_sliders: Array[VolumeSlider]) -> void:

	var bus_name := AudioServer.get_bus_name(bus_index)
	var slider_index := volume_sliders.find_custom(func(v: VolumeSlider): return v.volume_bus_name == bus_name)

	if slider_index < 0:
		push_error("audio settings: no volume slider corresponding to bus '{0}'".format({"0": bus_name}))
		return

	var slider := volume_sliders[slider_index]
	slider.volume_percent_updated.connect(func(f: float): _update_bus_volume.bind(bus_index).call(f))


func _update_bus_volume(new_volume_percent: float, bus_index: int) -> void:
	var normalized_percent = new_volume_percent / 100.0
	var volume_db = _get_volume_db(normalized_percent)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
