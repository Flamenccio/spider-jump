extends LevelEvent

@export var _sniper_shot_scene: PackedScene

## Time in seconds between shots
@export var _sniper_shot_frequency: float

var _sniper_shot_timer: Timer = Timer.new()

func _ready() -> void:
	_sniper_shot_timer.wait_time = _sniper_shot_frequency
	_sniper_shot_timer.one_shot = true
	_sniper_shot_timer.timeout.connect(_ready_shot)
	add_child(_sniper_shot_timer)


func start_event() -> void:
	_activated = true
	_ready_shot()


func end_event() -> void:
	queue_free()


func _ready_shot() -> void:
	var instance = _sniper_shot_scene.instantiate()
	instance.shot_fired.connect(_on_sniper_shot)
	GameConstants.game_spawner.add_child(instance)
	instance.set_target(GameConstants.player)


func _on_sniper_shot() -> void:
	_sniper_shot_timer.start()

