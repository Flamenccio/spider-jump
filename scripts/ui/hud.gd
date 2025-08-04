extends Control

signal external_health_lost(where: Control)

signal internal_stamina_updated(current_stamina: float)
signal internal_health_updated(current_health: int)
signal internal_score_updated(current_score: int)

func _ready() -> void:
	PlayerEventBus.player_stat_updated.connect(func(stat: String, value):
		match stat:
			'lives':
				_on_health_updated(value as int)
			'stamina':
				_on_stamina_updated(value as float)
			'score':
				_on_score_updated(value as int)
			_:
				return
	, ConnectFlags.CONNECT_DEFERRED)


func _on_stamina_updated(current_stamina: float) -> void:
	var processed_stamina := current_stamina * 100.0
	internal_stamina_updated.emit(processed_stamina)


func _on_health_updated(current_health: int) -> void:
	internal_health_updated.emit(current_health)


func _on_score_updated(current_score: int) -> void:
	internal_score_updated.emit(current_score)


func _internal_on_life_lost(screen_coords: Control) -> void:
	external_health_lost.emit(screen_coords)

