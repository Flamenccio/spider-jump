extends Control
## Displays text at the bottom of the screen, intended to be a hint
## for powerup usage.

signal text_requested(txt: String)

var _text_timer := Timer.new()

func _ready() -> void:
    _text_timer.one_shot = true
    _text_timer.autostart = false
    _text_timer.timeout.connect(clear_text)
    add_child(_text_timer)


## Display text on the hint label. If `timeout > 0`, the text clears after
## `timeout` seconds. Otherwise, the text stays indefinitely.
func display_text(txt: String, timeout: float = 0.0) -> void:
    text_requested.emit(txt)
    if timeout > 0:
        _text_timer.start(timeout)


func clear_text() -> void:
    text_requested.emit("")
