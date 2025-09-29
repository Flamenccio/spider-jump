class_name SoundManager
extends Node

const _DEFAULT_SOUND_DIRECTORY = "res://sounds/"
const _DEFAULT_MUSIC_DIRECTORY = "res://music/"

# File extension querying
const _FILE_EXTENSION_REGEX_BASE = "^.*\\"
const _OGG_EXTENSION = ".ogg"
const _MP3_EXTENSION = ".mp3"
const _WAV_EXTENSION = ".wav"
const _REGEX_END_STRING = "$"

var _ogg_regex := RegEx.new()
var _mp3_regex := RegEx.new()
var _wav_regex := RegEx.new()

var _sounds := {}
var _music := {}

## Searches for sound files recursively on ready.[br]
## If none given, searches through `res://sounds/` by default.
@export var _sounds_directories: Array[String]

## Searches for sound files recursively on ready.[br]
## If none given, searches through `res://music/` by default.
@export var _music_directories: Array[String]

func _ready() -> void:

	# Compile regex
	_ogg_regex.compile(_FILE_EXTENSION_REGEX_BASE + _OGG_EXTENSION + _REGEX_END_STRING)
	_mp3_regex.compile(_FILE_EXTENSION_REGEX_BASE + _MP3_EXTENSION + _REGEX_END_STRING)
	_wav_regex.compile(_FILE_EXTENSION_REGEX_BASE + _WAV_EXTENSION + _REGEX_END_STRING)

	# Load stuff
	if _sounds_directories.size() == 0:
		var full_paths = _load_sounds(_DEFAULT_SOUND_DIRECTORY)
		_sounds.merge(_to_dictionary(full_paths, _DEFAULT_SOUND_DIRECTORY))
	else:
		for d in _sounds_directories:
			var full_paths = _load_sounds(d)
			_sounds.merge(_to_dictionary(full_paths, d))

	if _music_directories.size() == 0:
		var full_paths = _load_sounds(_DEFAULT_MUSIC_DIRECTORY)
		_music.merge(_to_dictionary(full_paths, _DEFAULT_MUSIC_DIRECTORY))
	else:
		for d in _music_directories:
			var full_paths = _load_sounds(d)
			_music.merge(_to_dictionary(full_paths, d))


func _load_sounds(directory: String) -> Array[String]:

	var dir = DirAccess.open(directory)

	if not dir:
		push_warning("sound manager: invalid path '{0}'".format({"0": directory}))
		return []

	dir.list_dir_begin()
	var current_file := dir.get_next()
	var valid_paths: Array[String]

	while current_file != "":
		var full_path = '{0}/{1}'.format({'0': directory, '1': current_file})
		if dir.current_is_dir():
			valid_paths.append_array(_load_sounds(full_path))
		else:
			if _mp3_regex.search(full_path) or _ogg_regex.search(full_path) or _wav_regex.search(full_path):
				valid_paths.append(full_path)
		current_file = dir.get_next()

	dir.list_dir_end()
	return valid_paths


func _to_dictionary(paths: Array[String], parent_path: String) -> Dictionary:

	var dict: Dictionary
	for p in paths:
		var id = p.replace(parent_path + "/", "")
		id = id.replace(_MP3_EXTENSION, "")
		id = id.replace(_WAV_EXTENSION, "")
		id = id.replace(_OGG_EXTENSION, "")
		dict[id] = p

	return dict


## Play a nonpositional sound.
func play_sound(sound_id: String) -> void:
	## TODO: complete
	## TODO: make a sound player node class
	# must handle one-shot and persistent situations
	# must handle non-positional and positional situations
	var file_path = _sounds[sound_id]
	pass