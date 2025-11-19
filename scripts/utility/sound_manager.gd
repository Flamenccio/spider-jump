extends Node
## Handles non positional playing of sounds and music.

# Music buses
const _MUSIC_BUS = "Music"
const _MASTER_BUS = "Master"
const _SFX_BUS = "SFX"

# Default search directories
const _DEFAULT_SOUND_DIRECTORY = "res://sounds/"
const _DEFAULT_MUSIC_DIRECTORY = "res://music/"

# File extension querying
const _FILE_EXTENSION_REGEX_BASE = "^.*\\"
const _OGG_EXTENSION = ".ogg"
const _MP3_EXTENSION = ".mp3"
const _WAV_EXTENSION = ".wav"
const _IMPORT_SUFFIX = ".import"
const _REGEX_END_STRING = "$"

const _DEFAULT_POLYPHONY = 32

var _ogg_regex := RegEx.new()
var _mp3_regex := RegEx.new()
var _wav_regex := RegEx.new()
var _sounds_suppressed := false

var _sounds := {}
var _music := {}
var _main_global_sound_player: AudioStreamPlayer
var _main_music_player: AudioStreamPlayer
var _music_pause_timer := Timer.new()

func _ready() -> void:

	# Compile regex
	_ogg_regex.compile(_FILE_EXTENSION_REGEX_BASE + _OGG_EXTENSION + _REGEX_END_STRING)
	_mp3_regex.compile(_FILE_EXTENSION_REGEX_BASE + _MP3_EXTENSION + _REGEX_END_STRING)
	_wav_regex.compile(_FILE_EXTENSION_REGEX_BASE + _WAV_EXTENSION + _REGEX_END_STRING)

	# Create audio player
	_main_global_sound_player = AudioStreamPlayer.new()
	_main_global_sound_player.bus = _SFX_BUS
	_main_global_sound_player.max_polyphony = _DEFAULT_POLYPHONY
	add_child(_main_global_sound_player)

	# Create music player
	_main_music_player = AudioStreamPlayer.new()
	_main_music_player.bus = _MUSIC_BUS
	add_child(_main_music_player)

	# Load sounds
	_music = _to_dictionary(_load_sound_files(_DEFAULT_MUSIC_DIRECTORY), _DEFAULT_MUSIC_DIRECTORY)
	_sounds = _to_dictionary(_load_sound_files(_DEFAULT_SOUND_DIRECTORY), _DEFAULT_SOUND_DIRECTORY)


# ---
# DICTIONARY
# ---

func get_music() -> Dictionary:
	return _music.duplicate()


func get_sounds() -> Dictionary:
	return _sounds.duplicate()


# ---
# SOUND PLAYING
# ---

## Play a nonpositional sound with id `sound_id`.
func play_sound(sound_id: String) -> void:

	if _sounds_suppressed:
		return

	var sfx = load(_sounds.get(sound_id))

	if sfx == null:
		return
	if not _main_global_sound_player.has_stream_playback():
		var new_stream = AudioStreamPolyphonic.new()
		_main_global_sound_player.stream = new_stream
		_main_global_sound_player.play()

	var playback := _main_global_sound_player.get_stream_playback()
	playback.play_stream(sfx, 0.0, 0.0, 1.0, 0, _SFX_BUS)


## Stops all sounds started by [code]play_sound[/code].
func stop_all_sounds() -> void:
	_main_global_sound_player.stop()

# ---
# SOUND SUPPRESSION
# ---

## Prevents sounds from being played.
func suppress_sounds() -> void:
	_sounds_suppressed = true


## Allows sounds to be played.
func allow_sounds() -> void:
	_sounds_suppressed = false

# ---
# MUSIC PLAYING
# ---

func play_music(music_id: String) -> void:
	var audio_stream = load(_music.get(music_id))
	_main_music_player.stream = audio_stream
	_main_music_player.play()


func pause_music(pause_time: float = -1.0) -> void:
	_main_music_player.stream_paused = true
	if pause_time > 0.0:
		_music_pause_timer.start(pause_time)


func resume_music() -> void:
	_main_music_player.stream_paused = false


func stop_music() -> void:
	_main_music_player.stop()


func _load_sound_files(directory: String) -> Array[String]:

	var dir = DirAccess.open(directory)

	if not dir:
		push_warning("Invalid path '{0}'".format({"0": directory}))
		return []

	dir.list_dir_begin()
	var current_file := dir.get_next()
	var valid_paths: Array[String]

	while current_file != "":

		var full_path = '{0}/{1}'.format({'0': directory, '1': current_file})

		# Recursive call
		if dir.current_is_dir():
			valid_paths.append_array(_load_sound_files(full_path))
			current_file = dir.get_next()
			continue

		if _file_path_is_sound_file(full_path):
			valid_paths.erase(full_path)
			valid_paths.append(full_path)
		elif full_path.ends_with(_IMPORT_SUFFIX):
			var trimmed = full_path.trim_suffix(_IMPORT_SUFFIX)
			if _file_path_is_sound_file(trimmed) and not valid_paths.has(trimmed):
				valid_paths.append(trimmed)

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
		id = id.replace(".import", "")
		dict[id] = p
	
	return dict


func _file_path_is_sound_file(path: String) -> bool:
	return _mp3_regex.search(path) or _ogg_regex.search(path) or _wav_regex.search(path)
