extends Node2D

signal player_entered()
@export var _particle_emitter: SpriteParticleEmitter

var _death_timer: Timer = Timer.new()

const _DEATH_TIMER_DURATION = 3.0

func _ready() -> void:
	_death_timer.one_shot = true
	_death_timer.wait_time = _DEATH_TIMER_DURATION
	_death_timer.timeout.connect(func(): queue_free())
	add_child(_death_timer)


func _on_player_entered() -> void:
	_particle_emitter.spawn_particle('high_score', global_position)
	_death_timer.start()
	player_entered.emit()
