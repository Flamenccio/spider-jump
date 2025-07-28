extends Node2D

@export var _origin: Node2D
@export var _particle_prefab: PackedScene
@export_range(0, 100) var _particle_count: int = 10

var inactive_particles: Array[TrajectoryParticle]
var active_particles: Array[TrajectoryParticle]

var velocity: Vector2
var acceleration: Vector2

var activation_timer: Timer = Timer.new()

const _HALF = 0.50
const _ACTIVATION_FREQUENCY = 0.20

func _ready() -> void:

	# Instantiate prefabs
	for i in range(_particle_count):
		var instance = _particle_prefab.instantiate()
		if instance is not TrajectoryParticle:
			printerr('parabola particles: given prefab is not of type TrajectoryParticle')
			instance.queue_free()
			return
		var particle = instance as TrajectoryParticle
		particle.return_to_pool = _return_particle
		particle.point_on_path = path
		inactive_particles.push_back(particle)
		add_child(particle)
	
	# Set up timer
	activation_timer.wait_time = _ACTIVATION_FREQUENCY
	activation_timer.timeout.connect(_activate_next_particle)
	add_child(activation_timer)

	# Deactivate all
	deactivate_trajectory()


func path(t: float) -> Vector2:
	var x = velocity.x * t + _HALF * acceleration.x * pow(t, 2.0)
	var y = velocity.y * t + _HALF * acceleration.y * pow(t, 2.0)
	return Vector2(x, y) + _origin.global_position


func activate_trajectory() -> void:
	_activate_next_particle()
	activation_timer.start()


func deactivate_trajectory() -> void:
	activation_timer.stop()
	for i in range(active_particles.size()):
		var particle = active_particles.pop_front() as TrajectoryParticle
		particle.deactivate_particle()
		inactive_particles.push_back(particle)


func _activate_next_particle() -> void:
	var particle = inactive_particles.pop_front() as TrajectoryParticle
	if particle == null:
		print('parabola particles: ran out of particles!')
		return
	particle.global_position = _origin.global_position
	particle.activate_particle()
	active_particles.push_back(particle)


func _update_trajectory(new_velocity: Vector2, new_acceleration: Vector2) -> void:
	velocity = new_velocity
	acceleration = new_acceleration


func _return_particle(particle: TrajectoryParticle) -> void:
	var index = active_particles.find(particle)
	if index < 0:
		return
	var found = active_particles.pop_at(index)
	inactive_particles.push_back(found)

