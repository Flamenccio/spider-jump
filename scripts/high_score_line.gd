extends Node2D

signal player_entered()
@export var _particle_emitter: SpriteParticleEmitter
@export var _high_score_saver: Node

var _death_timer: Timer = Timer.new()

const _DEATH_TIMER_DURATION = 3.0

func _ready() -> void:
	_death_timer.one_shot = true
	_death_timer.wait_time = _DEATH_TIMER_DURATION
	_death_timer.timeout.connect(func(): queue_free())
	add_child(_death_timer)


func _on_stats_saver_ready() -> void:
	var high_score = _high_score_saver.get_high_score()

	# Move to high score elevation
	if high_score == 0 or high_score == null:
		# Do not show if there is no high score
		queue_free()
		return

	global_position = Vector2(0.0, -1 * high_score * GameConstants.PIXELS_PER_POINT)


func _on_player_entered() -> void:
	_particle_emitter.spawn_particle('high_score', global_position)
	_death_timer.start()
	player_entered.emit()
