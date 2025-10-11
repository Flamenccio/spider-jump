extends LevelEvent

@export var _wasp_scene: PackedScene
@export var _base_spawn_frequency: float = 2.0
var _wasp_spawn_timer: Timer = Timer.new()

const _MIN_SPAWN_FREQUENCY = 0.5
const _TILE_SIZE = 8.0
const _SCREEN_TILE_HEIGHT = 20.0

func _ready() -> void:
	_wasp_spawn_timer.wait_time = _base_spawn_frequency
	_wasp_spawn_timer.timeout.connect(_spawn_wasp)
	add_child(_wasp_spawn_timer)


func start_event() -> void:
	_activated = true
	_wasp_spawn_timer.start()


func end_event() -> void:
	_wasp_spawn_timer.stop()
	queue_free()


func _spawn_wasp() -> void:
	var direction := randf() >= 0.5
	var instance := _wasp_scene.instantiate() as Node2D
	call_deferred('_add_wasp', instance, direction)


func _add_wasp(wasp: Node2D, right_side: bool) -> void:

	GameConstants.game_spawner.add_child(wasp)
	var elevation_offset = -1 * roundf(randf_range(0, _TILE_SIZE * _SCREEN_TILE_HEIGHT))
	var player_elevation = GameConstants.player.global_position.y
	var spawn_position := Vector2.ZERO

	# Spawn on left side (wasp moves to the right, towards screen)
	if right_side:
		spawn_position = Vector2(-19 * _TILE_SIZE, player_elevation + elevation_offset)
	else:
		spawn_position = Vector2(19 * _TILE_SIZE, player_elevation + elevation_offset)

	wasp.global_position = spawn_position
	wasp.set_fly_direction(right_side)
