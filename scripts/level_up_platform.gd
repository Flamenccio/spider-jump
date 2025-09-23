extends StaticBody2D

signal platform_triggered()

const _LEVEL_UP_STAMINA_RESTORE = 1.0 / 3.0
const _MAX_TRIGGERS = 2

var _triggered := false
var _triggers: int = 0

"""
For the platform to trigger, the player must completely exit the platform trigger
(Area2D covering entire platform collider) and enter the secondary trigger
(another Area2D covering some part above the platform collider). This ensures
that the platform doesn't activate when the player is inside the platform.
"""

func _on_player_enter_secondary_trigger(body:Node2D) -> void:
	if _triggered:
		return
	_triggers = clampi(_triggers + 1, 0, _MAX_TRIGGERS)
	_attempt_platform_trigger(body)



func _on_player_exit_secondary_trigger() -> void:
	if _triggered:
		return
	_triggers = clampi(_triggers - 1, 0, _MAX_TRIGGERS)


func _on_player_enter_platform_trigger() -> void:
	if _triggered:
		return
	_triggers = clampi(_triggers - 1, 0, _MAX_TRIGGERS)


func _on_player_exit_platform_trigger(body: Node2D) -> void:
	if _triggered:
		return
	_triggers = clampi(_triggers + 1, 0, _MAX_TRIGGERS)
	_attempt_platform_trigger(body)


func _attempt_platform_trigger(player: Node2D) -> void:
	if _triggers >= _MAX_TRIGGERS:
		_triggered = true
		PlayerStatsInterface.change_stat.emit(PlayerStatsInterface.STATS_STAMINA, _LEVEL_UP_STAMINA_RESTORE)
		platform_triggered.emit()
		GlobalFlashParticleSpawner.spawn_particle("player_level_up_text", global_position, 0.0)
		player.call("on_level_up_platform_reached")