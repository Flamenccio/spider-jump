extends Node2D

signal attack_ended()
@export var _laser_scene: PackedScene
var active_lasers := 0
var completed_lasers := 0
var lasers_array: Array[Node2D]

const MAX_LASERS = 3
const MIN_LASERS = 1

# How wide the playing area is in tiles
const GAME_WIDTH_TILES = 12
const TILE_SIZE = 8

func _ready() -> void:
	if _laser_scene == null:
		push_error('laser attack: laser scene is null')
		return


func start_attack() -> void:
	var lasers = randi_range(MIN_LASERS, MAX_LASERS)
	active_lasers = lasers
	var available_tiles := range(GAME_WIDTH_TILES)
	for i in range(lasers):
		var tile = available_tiles.pick_random()
		available_tiles.erase(tile)
		var horizontal = tile * TILE_SIZE - (GAME_WIDTH_TILES / 2.0) * TILE_SIZE
		var instance := _laser_scene.instantiate()
		lasers_array.append(instance)
		instance.connect('laser_attack_finished', _on_laser_attack_finished)
		call_deferred('add_laser', instance, horizontal)


func add_laser(laser: Node2D, horizontal_offset: float) -> void:
	add_child(laser)
	laser.position = Vector2(horizontal_offset, 0)


func _on_laser_attack_finished() -> void:
	completed_lasers += 1
	if completed_lasers >= active_lasers:
		for laser in lasers_array:
			laser.queue_free()
		lasers_array.clear()
		completed_lasers = 0
		attack_ended.emit()

