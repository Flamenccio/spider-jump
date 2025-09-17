extends RigidBody2D

enum RaindropSize {
	SMALL,
	MEDIUM,
	LARGE,
}

const _TOTAL_BOUNCES = 6
const _BURST_FORCE_LARGE = 20
const _BURST_FORCE_MEDIUM = 10
const _BURST_FORCE_SMALL = 5

var _bounces_left: int

## Sprites for different sizes. Smaller -> larger.
@export var _sprites: Array[Texture2D]
@export var _sprite: Sprite2D
@export_flags_2d_physics var _bounce_layers: int
@export_flags_2d_physics var _player_layer: int

func initiate_raindrop(initial_raindrop_size: RaindropSize = RaindropSize.LARGE) -> void:
	_bounces_left = _get_bounces_left(initial_raindrop_size)
	_set_sprite(initial_raindrop_size)


func _get_bounces_left(raindrop_size: RaindropSize) -> int:
	return floori(_TOTAL_BOUNCES * (raindrop_size + 1) / RaindropSize.size())


func _set_sprite(raindrop_size: RaindropSize) -> void:
	_sprite.texture = _sprites[raindrop_size]


func _on_body_entered(body:Node) -> void:

	if body is not CollisionObject2D:
		return

	var col = body as CollisionObject2D
	
	if col.collision_layer | _bounce_layers > 0:
		_bounce()
	elif col.collision_layer | _player_layer > 0:
		_hit_player()


func _bounce() -> void:
	if _bounces_left <= 0:
		_burst()
	_bounces_left -= 1


func _hit_player() -> void:
	_burst()


func _burst() -> void:
	pass