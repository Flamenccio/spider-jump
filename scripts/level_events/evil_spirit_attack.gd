extends LevelEvent

var _evil_spirit_instance: Node2D

@export var _evil_spirit_scene: PackedScene

func start_event() -> void:
	_activated = true
	_evil_spirit_instance = _evil_spirit_scene.instantiate() as Node2D
	var player = GameConstants.player
	GameConstants.game_spawner.call_deferred("add_child", _evil_spirit_instance)
	_evil_spirit_instance.global_position = player.global_position
	_evil_spirit_instance.target = player
	_evil_spirit_instance.set_event_origin(player.global_position)


func end_event() -> void:
	_evil_spirit_instance.queue_free()
	queue_free()