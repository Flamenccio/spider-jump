extends PlayerAction

@export var _crawl_speed: float
var _move_input: Vector2

func _ready() -> void:
	"""
	if _player_rb == null:
		printerr('crawl: rb is null')
		return
	"""
	pass


func _on_move_input_change(move_input: Vector2) -> void:
	#_move_input = move_input
	pass


func _physics_process(delta: float) -> void:
	
	"""
	if not action_active:
		return

	var horizontal = _move_input - Vector2(0, _move_input.y)
	var crawl_vector = horizontal.rotated(_player_rb.rotation)

	# Only move and collide when input is given
	if crawl_vector.length() == 0:
		return

	_player_rb.move_and_collide(crawl_vector * _crawl_speed * delta)
	"""
