class_name TrajectoryParticle
extends AnimatedSprite2D

var active: bool = false

## Accepts float `t` as a parameter and returns a Vector2
var point_on_path: Callable

## Accepts a `TrajectoryParticle` as a parameter and has no return value
var return_to_pool: Callable

# When `t` reaches this value, the particle will deactivate
const MAX_T: float = 1.0
var t: float = 0.0

func activate_particle() -> void:
	active = true
	play(&"default")
	show()


func deactivate_particle() -> void:
	active = false
	stop()
	t = 0.0
	return_to_pool.call(self as TrajectoryParticle)
	hide()


func _process(delta: float) -> void:
	if not active: return
	if t >= MAX_T:
		deactivate_particle()
	var point = point_on_path.call(t) as Vector2
	global_position = point
	t += delta
