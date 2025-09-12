extends StaticBody2D

signal shot_fired()
signal telegraph()

const LERP_WEIGHT = 0.01
const DANGER_FLASH_PARTICLE = "danger_flash_2"

var _aim_timer: Timer = Timer.new()
var _target: Node2D
var _aiming := true
var _fired := false
var _position_lerp_weight = LERP_WEIGHT

@export var _aim_duration: float = 1.0

func _ready() -> void:
	_aim_timer.one_shot = true
	_aim_timer.wait_time = _aim_duration
	_aim_timer.timeout.connect(_fire)
	add_child(_aim_timer)


func set_target(t: Node2D) -> void:
	_target = t
	global_position = _target.global_position
	_aim_timer.start()


func _physics_process(delta: float) -> void:
	if _aiming:
		var between = global_position.lerp(_target.global_position, _position_lerp_weight)
		global_position = between
		_position_lerp_weight += delta / 15.0


func _on_animation_finished() -> void:
	if not _aiming and not _fired:
		shot_fired.emit()
		_fired = true
		return
	if not _aiming and _fired:
		queue_free()
		return


func _fire() -> void:
	GlobalFlashParticleSpawner.spawn_particle(DANGER_FLASH_PARTICLE, global_position, 0.0)
	GlobalFlashParticleSpawner.spawn_particle(DANGER_FLASH_PARTICLE, global_position, PI / 2.0)
	_aiming = false
	telegraph.emit()

