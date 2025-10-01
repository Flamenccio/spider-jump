extends Control

signal display_elements()
signal hide_elements()

const _EVENT_KEY_PREFIX = "event."
var _show := false
var _display_timer := Timer.new()

@export var _display_time_seconds: float
@export var _event_label: Label
@export var _banner: Node

func _ready() -> void:
	_display_timer.one_shot = true
	_display_timer.wait_time = _display_time_seconds
	_display_timer.timeout.connect(_go_away)
	add_child(_display_timer)
	_banner.transition_animation_finished.connect(_go_away_for_real)


func start_event(event_id: String) -> void:
	_show = true
	show()
	display_elements.emit()
	_event_label.text = tr(_EVENT_KEY_PREFIX + event_id)
	_banner.play_enter_animation()
	_display_timer.start()


func _go_away() -> void:
	_show = false
	hide_elements.emit()
	_banner.play_exit_animation()


func _go_away_for_real() -> void:
	if _show: return
	hide()