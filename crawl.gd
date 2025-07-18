extends PlayerAction

@export var _crawl_speed: float
var _move_input: Vector2

func _ready() -> void:
	if _player_rb == null:
		printerr('crawl: rb is null')
		return


func _on_move_input_change(move_input: Vector2) -> void:
	_move_input = move_input


func _physics_process(delta: float) -> void:

	if not action_active:
		return

	var horizontal = _move_input - Vector2(0, _move_input.y)
	var crawl_vector = horizontal.rotated(_player_rb.rotation)

	# Only move and collide when input is given
	if crawl_vector.length() == 0:
		_player_rb.constant_force = Vector2.ZERO
		return

	_player_rb.move_and_collide(crawl_vector * _crawl_speed * delta)
	#_player_rb.add_constant_force(crawl_vector * _crawl_speed * delta)
