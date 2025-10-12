class_name SettingsManager
extends Node

const _SETTINGS_DIRECTORY = "res://resources/settings/"
const _SETTINGS_RESOURCE = "player_settings.res"
const _DEFAULT_AUDIO_LEVEL = 0.75

var _settings_path: String
var _settings: UserSettings

func _ready() -> void:
	_settings_path = _SETTINGS_DIRECTORY + _SETTINGS_RESOURCE
	_load_settings()
	apply_settings()


func apply_settings() -> void:
	_apply_audio_settings()


func update_audio_setting(new_audio_levels: Dictionary) -> void:
	_load_settings()
	_settings.audio_levels.assign(new_audio_levels)
	ResourceSaver.save(_settings, _settings_path)


## Reads the current AudioServer bus volumes and saves it to the player's settings
func update_audio_settings_from_server() -> void:

	var buses := AudioServer.bus_count
	var bus_volumes := {}

	for i in buses:
		bus_volumes[AudioServer.get_bus_name(i)] = AudioServer.get_bus_volume_linear(i)

	update_audio_setting(bus_volumes)


func _load_settings() -> void:

	var s = ResourceLoader.load(_settings_path)

	if s == null:
		_create_default_settings()
		return
	
	if s is not UserSettings:
		_create_default_settings()
		return

	_settings = s as UserSettings


func _apply_audio_settings() -> void:

	var audio_levels = _settings.audio_levels
	
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
