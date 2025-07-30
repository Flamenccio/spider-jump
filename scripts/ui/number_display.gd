extends HFlowContainer

var _digit_displays: Array[DigitDisplay]
var _MAX_VALUE: int = 0
var _digits: int = 0

@export var _initial_value: int = 0

func _ready() -> void:
	var children = get_children()
	for child in children:
		if child is DigitDisplay:
			_digit_displays.append(child as DigitDisplay)

	# Returns a sorted array based on position, rotation, RID, etc.
	var sort_function = func(a: DigitDisplay, b: DigitDisplay):
		return true

	# Sort by x position
	_digit_displays.sort_custom(sort_function)
	_digits = _digit_displays.size()
	for i in range(_digits):
		_MAX_VALUE += roundi(9 * pow(10, i))
	display_value(_initial_value)


func display_value(display: int) -> void:
	display = clampi(display, 0, _MAX_VALUE)
	var current_digit := 0
	for i in range(_digits):
		current_digit = floori(display / pow(10, i)) % 10
		_digit_displays[i].display_digit(current_digit)

