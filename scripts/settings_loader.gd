class_name SettingsManager
extends Node

const _SETTINGS_DIRECTORY = "res://resources/settings/"
const _SETTINGS_RESOURCE = "player_settings.res"
const _DEFAULT_AUDIO_LEVEL = 0.75

var _settings_path: String
var _hot_settings: UserSettings

func _ready() -> void:
	_settings_path = _SETTINGS_DIRECTORY + _SETTINGS_RESOURCE
	_load_settings()
	apply_settings()


## Get the current values for each player setting, where each
## dicitionary key is the property's name, and the value is
## the property's value.
func get_settings() -> Dictionary:
	var dict = {
		"tutorial_played": _hot_settings.tutorial_played,
		"repeat_tutorial": _hot_settings.repeat_tutorial,
		"audio_levels": _hot_settings.audio_levels
	}
	return dict


func apply_settings() -> void:
	_apply_audio_settings()


func write_settings() -> void:
	ResourceSaver.save(_hot_settings, _settings_path)


func update_audio_setting(new_audio_levels: Dictionary) -> void:
	_load_settings()
	_hot_settings.audio_levels.assign(new_audio_levels)
	ResourceSaver.save(_hot_settings, _settings_path)


func update_setting(setting_name: String, setting_value) -> void:

	var property_list = _hot_settings.get_property_list()
	var setting_idx = property_list.find_custom(
		func(d: Dictionary):
			return d.get("name", "") == setting_name
	)

	if setting_idx < 0:
		push_warning("Setting '{0}' doesn't exist.".format({"0": setting_name}))
		return

	var property = property_list[setting_idx]
	if property.get("type") != typeof(setting_value):
		push_warning("Setting '{0}' is of type '{1}', trying to set as type '{2}'".format(
			{
				"0": setting_name, 
				"1": property.get("type"), 
				"2": typeof(setting_value)}
		))
		return

	_hot_settings.set(setting_name, setting_value)


## Reads the current AudioServer bus volumes and saves it to the player's settings
func update_audio_settings_from_server() -> void:

	var buses := AudioServer.bus_count
	var bus_volumes := {}

	for i in buses:
		bus_volumes[AudioServer.get_bus_name(i)] = AudioServer.get_bus_volume_linear(i)
		print("{0}: {1}".format({"0": AudioServer.get_bus_name(i), "1": AudioServer.get_bus_volume_linear(i)}))

	update_audio_setting(bus_volumes)


func _load_settings() -> void:

	var s = ResourceLoader.load(_settings_path)

	if s == null:
		_create_default_settings()
		return
	
	if s is not UserSettings:
		_create_default_settings()
		return

	_hot_settings = s as UserSettings


func _apply_audio_settings() -> void:

	var audio_levels = _hot_settings.audio_levels
	
	for k in audio_levels.keys():
		var bus_index = AudioServer.get_bus_index(k)
		if bus_index < 0:
			push_warning("settings loader: no audio bus named '{0}'".format({"0": k}))
			continue
		AudioServer.set_bus_volume_linear(bus_index, audio_levels[k])


func _create_default_settings() -> void:
	var fresh := UserSettings.new()
	fresh.audio_levels.assign(_create_default_audio_settings())
	ResourceSaver.save(fresh, _settings_path)


func _create_default_audio_settings() -> Dictionary:

	var buses := AudioServer.bus_count
	var audio_settings := {}

	for i in range(buses):
		var bus_name := AudioServer.get_bus_name(i)
		audio_settings[bus_name] = _DEFAULT_AUDIO_LEVEL

	return audio_settings
