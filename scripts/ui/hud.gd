extends Control

signal external_health_lost(where: Control)

signal internal_difficulty_level_updated(difficulty_level: int)
signal internal_stamina_updated(current_stamina: float)
signal internal_health_updated(current_health: int)
signal internal_score_updated(current_score: int)
signal internal_powerup_started(powerup: String)
signal internal_powerup_ended()
signal internal_powerup_timer_updated(powerup_time: float, powerup_max_time: float)

func _ready() -> void:
	PlayerEventBus.player_stat_updated.connect(func(stat: String, value):
		match stat:
			PlayerStatsInterface.STATS_HEALTH:
				_on_health_updated(value as int)
			PlayerStatsInterface.STATS_STAMINA:
				_on_stamina_updated(value as float)
			PlayerStatsInterface.STATS_SCORE:
				_on_score_updated(value as int)
			_:
				return
	, ConnectFlags.CONNECT_DEFERRED)
	PlayerEventBus.powerup_started.connect(func(powerup: String): internal_powerup_started.emit(powerup), ConnectFlags.CONNECT_DEFERRED)
	PlayerEventBus.powerup_ended.connect(func(_d: String): internal_powerup_ended.emit(), ConnectFlags.CONNECT_DEFERRED)
	PlayerEventBus.powerup_timer_updated.connect(func(time_left: float, duration: float): internal_powerup_timer_updated.emit(time_left, duration), ConnectFlags.CONNECT_DEFERRED)


func _on_stamina_updated(current_stamina: float) -> void:
	var processed_stamina := current_stamina * 100.0
	internal_stamina_updated.emit(processed_stamina)


func _on_health_updated(current_health: int) -> void:
	internal_health_updated.emit(current_health)


func _on_score_updated(current_score: int) -> void:
	internal_score_updated.emit(current_score)


func _internal_on_life_lost(screen_coords: Control) -> void:
	external_health_lost.emit(screen_coords)


func _on_difficulty_level_updated(level: int) -> void:
	internal_difficulty_level_updated.emit(level)

