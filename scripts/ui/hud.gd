extends Control

signal life_bar_depleted(control: Control)

@export var _life_bar_decrease_particles: PackedScene

# UI elements
@onready var _stamina_bar := %StaminaBar
@onready var _life_bar := %LifeBar
@onready var _score_display := %ScoreDisplay
@onready var _powerup_time_bar := %PowerupTimeBar
@onready var _extra_level_display := %LevelLabel
@onready var _extra_high_score_display := %HighScoreLabel

func _ready() -> void:
	PlayerEventBus.player_stat_updated.connect(_on_player_stat_updated, ConnectFlags.CONNECT_DEFERRED)
	PlayerEventBus.powerup_started.connect(_on_powerup_started)
	PlayerEventBus.powerup_ended.connect(_on_powerup_ended)
	PlayerEventBus.powerup_timer_updated.connect(_on_powerup_timer_updated)
	PlayerEventBus.player_fell.connect(_on_player_fell)


func _on_player_fell(_w: Vector2) -> void:
	var instance = _life_bar_decrease_particles.instantiate()
	GameConstants.game_spawner.add_child(instance)
	instance.call("spawn_particles", _life_bar)


func _on_record_keeper_ready() -> void:
	var score_string = str(GameConstants.high_score).pad_zeros(6)
	var label_text = "{0}: {1}".format({"0": tr("ui.label.generic.high_score"), "1": score_string})
	_extra_high_score_display.text = label_text


func _on_player_stat_updated(stat: String, stat_value) -> void:
	match stat:
		PlayerStatsInterface.STATS_HEALTH:
			_on_health_updated(stat_value as int)
		PlayerStatsInterface.STATS_STAMINA:
			_on_stamina_updated(stat_value as float)
		PlayerStatsInterface.STATS_SCORE:
			_on_score_updated(stat_value as int)
		_:
			return


func _on_stamina_updated(current_stamina: float) -> void:
	var processed_stamina := current_stamina * 100.0
	_stamina_bar.value = processed_stamina


func _on_health_updated(current_health: int) -> void:
	if  current_health < _life_bar.life_value:
		life_bar_depleted.emit(_life_bar)
	_life_bar.display_life(current_health)


func _on_score_updated(current_score: int) -> void:
	_score_display.display_value(current_score)


func _on_difficulty_level_updated(level: int) -> void:
	_extra_level_display.text = "{0} {1}".format({"0": tr("ui.label.hud.level"), "1": level})


func _on_powerup_started(_powerup: String) -> void:
	_powerup_time_bar.value = 100.0
	_powerup_time_bar.show()


func _on_powerup_ended(_powerup: String) -> void:
	_powerup_time_bar.hide()


func _on_powerup_timer_updated(time_left: float, duration: float) -> void:
	var progress = time_left / duration * 100.0
	_powerup_time_bar.value = progress
