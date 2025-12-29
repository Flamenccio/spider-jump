extends Sprite2D

@export var _active_sprite: Texture2D
@export var _inactive_sprite: Texture2D
@export var _invalid_sprite: Texture2D
@export var _hover_active_sprite: Texture2D
@export var _hover_inactive_sprite: Texture2D
@export var _start_active: bool = true

var invalid := false
var active: bool = false
var hovering: bool = false
var hover_powerup: bool = false:
	set(value):
		var new_tex: Texture2D
		if value:
			if active:
				new_tex = _hover_active_sprite
			else:
				new_tex = _hover_inactive_sprite
		else:
			if active:
				new_tex = _inactive_sprite
			else:
				new_tex = _active_sprite
		texture = new_tex
		hovering = value
	get:
		return hovering


func _ready() -> void:
	if _start_active:
		set_active()
	else:
		set_inactive()
	PlayerEventBus.powerup_started.connect(_handle_powerup)
	PlayerEventBus.powerup_ended.connect(_handle_powerup_end)
	PlayerEventBus.player_aim.connect(_on_player_aim)


func _on_player_aim(_direction: Vector2, is_valid: bool) -> void:

	if invalid == not is_valid:
		return

	invalid = not is_valid
	if not is_valid:
		set_invalid()
	else:
		if active:
			set_active()
		else:
			set_inactive()


func set_active() -> void:
	active = true
	if hover_powerup:
		texture = _hover_active_sprite
	else:
		if invalid:
			texture = _invalid_sprite
		else:
			texture = _active_sprite


func set_inactive() -> void:
	active = false
	if hover_powerup:
		texture = _hover_inactive_sprite
	else:
		texture = _inactive_sprite


func set_invalid() -> void:
	texture = _invalid_sprite


func _handle_powerup(powerup: String) -> void:
	if powerup == ItemIds.HOVERFLY_POWERUP:
		hover_powerup = true
	elif powerup == ItemIds.BLINKFLY_POWERUP:
		hide()


func _handle_powerup_end(powerup: String) -> void:
	if powerup == ItemIds.HOVERFLY_POWERUP:
		hover_powerup = false
	elif powerup == ItemIds.BLINKFLY_POWERUP:
		show()
