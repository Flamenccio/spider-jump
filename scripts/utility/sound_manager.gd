class_name SoundManager
extends Node
## Handles non positional playing of sounds and music.

signal sound_effect_finished(sound_id: String)

const _DEFAULT_SOUND_DIRECTORY = "res://sounds/"
const _DEFAULT_MUSIC_DIRECTORY = "res://music/"

# File extension querying
const _FILE_EXTENSION_REGEX_BASE = "^.*\\"
const _OGG_EXTENSION = ".ogg"
const _MP3_EXTENSION = ".mp3"
const _WAV_EXTENSION = ".wav"
const _REGEX_END_STRING = "$"

# Sound players
const _DEFAULT_MAX_PLAYERS = 20
const _DEFAULT_POLYPHONY = 1

var _ogg_regex := RegEx.new()
var _mp3_regex := RegEx.new()
var _wav_regex := RegEx.new()
var _sounds_suppressed := false

# Sound dictionaries
## Readonly copy of sounds dictionary
var sounds: Dictionary:
	get:
		return _sounds.duplicate()
	set(value):
		return
## Readonly copy of music dictionary
var music: Dictionary:
	get:
		return _music.duplicate()
	set(value):
		return
var _sounds := {}
var _music := {}
var _available_sound_players: Array[AudioStreamPlayer]
var _busy_sound_players: Array[AudioStreamPlayer]
var _main_music_player: AudioStreamPlayer
var _music_pause_timer := Timer.new()

## Searches for sound files recursively on ready.[br]
## If none given, searches through `res://sounds/` by default.
@export var _sounds_directories: Array[String]

## Searches for sound files recursively on ready.[br]
## If none given, searches through `res://music/` by default.
@export var _music_directories: Array[String]

## If `-1`, uses `_DEFAULT_MAX_PLAYERS`, 20
@export var _max_players: int = -1

func _ready() -> void:

	_max_players = _max_players if _max_players > -1 else _DEFAULT_MAX_PLAYERS

	# Compile regex
	_ogg_regex.compile(_FILE_EXTENSION_REGEX_BASE + _OGG_EXTENSION + _REGEX_END_STRING)
	_mp3_regex.compile(_FILE_EXTENSION_REGEX_BASE + _MP3_EXTENSION + _REGEX_END_STRING)
	_wav_regex.compile(_FILE_EXTENSION_REGEX_BASE + _WAV_EXTENSION + _REGEX_END_STRING)

	# Load stuff
	if _sounds_directories.size() == 0:
		# If loading from default locations and not the global sound manager,
		# copy the loaded sounds from the global sound manager
		if GlobalSoundManager != self:
			_sounds.assign(GlobalSoundManager.sounds)
		else:
			var full_paths = _load_sounds(_DEFAULT_SOUND_DIRECTORY)
			_sounds.merge(_to_dictionary(full_paths, _DEFAULT_SOUND_DIRECTORY))
	else:
		for d in _sounds_directories:
			var full_paths = _load_sounds(d)
			_sounds.merge(_to_dictionary(full_paths, d))

	if _music_directories.size() == 0:
		if GlobalSoundManager != self:
			_music.assign(GlobalSoundManager.music)
		else:
			var full_paths = _load_sounds(_DEFAULT_MUSIC_DIRECTORY)
			_music.merge(_to_dictionary(full_paths, _DEFAULT_MUSIC_DIRECTORY))
	else:
		for d in _music_directories:
			var full_paths = _load_sounds(d)
			_music.merge(_to_dictionary(full_paths, d))

	_main_music_player = AudioStreamPlayer.new()
	_main_music_player.bus = "Music"
	add_child(_main_music_player)

	_music_pause_timer.wait_time = 1.0
	_music_pause_timer.one_shot = true
	_music_pause_timer.timeout.connect(func(): resume_music())
	add_child(_music_pause_timer)


## Play a nonpositional sound with id `sound_id`.
func play_sound(sound_id: String, bus: String = "Master") -> void:
	print("played sound")
	if _sounds_suppressed:
		return
	var file_path = _sounds[sound_id] as String
	_enqueue_sound(_get_audio_stream(file_path), bus, sound_id)


func stop_all_sounds() -> void:
	print("stopping sounds")
	for b in _busy_sound_players:
		b.stop()
		b.stream = null
		_available_sound_players.push_back(b)
		_busy_sound_players.erase(b)


## Prevents sounds from being played.
func suppress_sounds() -> void:
	print("suppressing sounds")
	_sounds_suppressed = true


## Allows sounds to be played.
func allow_sounds() -> void:
	_sounds_suppressed = false


func play_music(music_id: String) -> void:
	_main_music_player.stream = _get_audio_stream(_music[music_id])
	_main_music_player.play()


func pause_music(pause_time: float = -1.0) -> void:
	_main_music_player.stream_paused = true
	_music_pause_timer.start(pause_time)


func resume_music() -> void:
	_main_music_player.stream_paused = false


func stop_music() -> void:
	_main_music_player.stop()


func _get_audio_stream(stream_path: String) -> AudioStream:
	if stream_path.contains(_MP3_EXTENSION):
		return AudioStreamMP3.load_from_file(stream_path)
	elif stream_path.contains(_OGG_EXTENSION):
		return AudioStreamOggVorbis.load_from_file(stream_path)
	elif stream_path.contains(_WAV_EXTENSION):
		return AudioStreamWAV.load_from_file(stream_path)
	else:
		push_warning("sound manager: invalid audio '{0}'".format({"0": stream_path}))
		return null


func _enqueue_sound(sound: AudioStream, bus: String, sound_id: String) -> void:

	# All available sound players are busy
	if _busy_sound_players.size() >= _max_players:
		push_warning("sound manager: ran out of audio players!")
		return

	# Use an available sound player
	if _available_sound_players.size() > 0:
		var next_player = _available_sound_players.pop_front()
		next_player.stream = sound
		next_player.bus = bus
		next_player.finished.connect(emit_signal.bind("sound_effect_finished", sound_id), ConnectFlags.CONNECT_ONE_SHOT)
		next_player.play()
		return

	# Make another sound player
	if _available_sound_players.size() == 0:
		var new_player = AudioStreamPlayer.new()
		add_child(new_player)
		new_player.max_polyphony = _DEFAULT_POLYPHONY
		new_player.finished.connect(emit_signal.bind("sound_effect_finished", sound_id), ConnectFlags.CONNECT_ONE_SHOT)
		new_player.finished.connect(_return_player.bind(new_player))
		new_player.stream = sound
		new_player.bus = bus
		new_player.play()
		return


func _return_player(player: AudioStreamPlayer) -> void:
	player.stop()
	player.stream = null
	_busy_sound_players.erase(player)
	_available_sound_players.push_back(player)


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

