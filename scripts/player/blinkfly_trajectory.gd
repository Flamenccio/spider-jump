extends Line2D

const _POINT_A_IDX = 0
const _POINT_B_IDX = 1

@export var _flash_texture: Texture2D
@export var _normal_texture: Texture2D
@export var _target_a: Node2D
@export var _target_b: Node2D
@export_flags_2d_physics var _raycast_hit_layers: int

var _active := false
var _raycast_query := RaycastQuery.new()

func _ready() -> void:

	_raycast_query.source = _target_a
	_raycast_query.collision_mask = _raycast_hit_layers

	PlayerEventBus.powerup_started.connect(func(powerup: String):
		if powerup == ItemIds.BLINKFLY_POWERUP:
			activate()
	)
	GlobalInputServer.pull_pressed.connect(func():
		texture = _flash_texture
		material.set_shader_parameter("speed_x", 0.0)
	)
	PlayerEventBus.powerup_ended.connect(func(powerup: String):
		if powerup == ItemIds.BLINKFLY_POWERUP:
			deactivate()
	)
	PlayerEventBus.player_jumped.connect(func(_w):
		texture = _normal_texture
		material.set_shader_parameter("speed_x", -2.0)
		hide()
	)
	PlayerEventBus.player_landed.connect(func(_w):
		show()
	)


func activate() -> void:
	add_point(_target_a.global_position)
	add_point(_target_b.global_position)
	_active = true


func deactivate() -> void:
	clear_points()
	_active = false


func set_bridge(node_a: Node2D, node_b: Node2D) -> void:
	if node_a == null or node_b == null:
		push_warning("At least one given node is null")
		return
	_target_a = node_a
	_target_b = node_b
	activate()


func _process(_delta: float) -> void:
	if not _active:
		return
	if _target_a == null or _target_b == null:
		deactivate()
		return

	var ray_results = _raycast_query.raycast_query(_target_a.global_position, _target_b.global_position)
	var to = _target_b.global_position

	if not ray_results.is_empty():
		to = ray_results.get("position")

	set_point_position(_POINT_A_IDX, _target_a.global_position)
	set_point_position(_POINT_B_IDX, to)
