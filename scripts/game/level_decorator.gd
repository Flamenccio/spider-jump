extends Node

const _SWIFT_YUMFLY_MIN_LEVEL = 7
const _SWIFT_YUMFLY_PROBABILITY = 0.50


var height: float = 0.0
var no_powerups: bool = false
var _active_swift_yumflies := 0
var _swift_yumfly_scene: PackedScene

@export var _game_manager: Node
@export var _decorations: Array[LevelDecoration]

func _ready() -> void:
	PlayerEventBus.powerup_started.connect(func(_powerup: String):
		no_powerups = true
	)
	PlayerEventBus.powerup_ended.connect(func(_powerup: String):
		no_powerups = false
	)
	_swift_yumfly_scene = load(ResourceUID.uid_to_path("uid://bmyyp1qc3tf0m"))


func _on_level_spawned(level: Node2D) -> void:
	_decorate_level(level)


func _on_game_height_updated(updated_height: float) -> void:
	height = updated_height


func _decorate_level(level_body: Node2D) -> void:
	_scan_elevation(level_body)
	_unpack_object_switch(level_body) # Must run before `_unpack_item_boxes`
	_unpack_item_boxes(level_body)
	call_deferred("_spawn_swift_yumfly", level_body)
	#_spawn_swift_yumfly(level_body)


func _scan_elevation(level: Node2D) -> void:
	var bottom = level.global_position.y
	var top = height
	var next_level_up_elevation = -1 * _game_manager.get_next_level_up_score(GameConstants.difficulty) * GameConstants.PIXELS_PER_POINT

	# Spawn a level up platform
	if next_level_up_elevation < bottom and next_level_up_elevation >= top:
		var plat = _get_level_decoration('level_up_platform')
		var spawn_position = Vector2(0.0, next_level_up_elevation)
		var instance = plat.instantiate_decoration(spawn_position, 0.0)
		level.add_child(instance)
		instance.global_position = spawn_position


func _get_level_decoration(decoration: String) -> LevelDecoration:
	var index = _decorations.find_custom(func(d: LevelDecoration): return d.decoration_name == decoration)
	if index < 0:
		printerr('level_decorator: no decoration with name "{0}"'.format({'0': decoration}))
		return null
	return _decorations[index]


func _unpack_item_boxes(level: Node2D) -> void:
	var children = level.get_children(true)
	for child in children:
		if child is ItemBox:
			if no_powerups:
				(child as ItemBox).spawn_loot(0)
				continue
			(child as ItemBox).spawn_loot(GameConstants.difficulty)


func _unpack_object_switch(level: Node2D) -> void:
	var children = level.get_children(true)
	for child in children:
		if child is ObjectSwitch:
			var objects = (child as ObjectSwitch).choose_objects()
			for obj in objects:
				level.add_child(obj)


func _spawn_swift_yumfly(level: Node2D) -> void:

	if GameConstants.difficulty < _SWIFT_YUMFLY_MIN_LEVEL:
		return
	if _active_swift_yumflies >= 1:
		return
	if randf() < _SWIFT_YUMFLY_PROBABILITY:
		return
	
	var children = level.get_children(true)
	children = children.filter(func(c: Node): return c is Item)
	children = children.filter(func(i: Item): return i.item_id == ItemIds.YUMFLY_ITEM)

	if children.size() == 0:
		print("failed to spawn swift yumfly: no replacements")
		return

	_active_swift_yumflies = 1
	var replace = children.pick_random() as Item
	var replacement_position = replace.global_position
	replace.queue_free()

	var instance = _swift_yumfly_scene.instantiate() as Item
	instance.tree_exiting.connect(func(): _active_swift_yumflies -= 1, ConnectFlags.CONNECT_ONE_SHOT)
	instance.global_position = replacement_position
	#TheGlobalSpawner.call_deferred("add_child", instance)
	get_tree().root.call_deferred("add_child", instance)
