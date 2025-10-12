extends UIScreen

func _ready() -> void:
	_init_sliders()


func _init_sliders() -> void:
	var children = _get_children_recursive(self)
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
	
	var current_volume := AudioServer.get_bus_volume_linear(bus_index)
	var current_bus_name := AudioServer.get_bus_name(bus_index)
	var slider_index := volume_sliders.find_custom(func(v: VolumeSlider): return v.volume_bus_id == current_bus_name)

	if slider_index < 0:
		return false

	var slider := volume_sliders[slider_index]
	slider.set_volume_percent(current_volume * 100.0)
	return true


func _attach_slider_listener(bus_index: int, volume_sliders: Array[VolumeSlider]) -> void:

	var bus_name := AudioServer.get_bus_name(bus_index)
	var slider_index := volume_sliders.find_custom(func(v: VolumeSlider): return v.volume_bus_id == bus_name)

	if slider_index < 0:
		push_error("audio settings: no volume slider corresponding to bus '{0}'".format({"0": bus_name}))
		return

	var slider := volume_sliders[slider_index]
	slider.volume_percent_updated.connect(func(f: float): _update_bus_volume.bind(bus_index).call(f))


func _update_bus_volume(new_volume_percent: float, bus_index: int) -> void:
	AudioServer.set_bus_volume_linear(bus_index, new_volume_percent / 100.0)


func _get_children_recursive(node: Node) -> Array[Node]:
	var arr: Array[Node]
	for c in node.get_children():
		arr.append(c)
		arr.append_array(_get_children_recursive(c))
	return arr


func _on_audio_settings_exit() -> void:
	SettingsService.update_audio_settings_from_server()

