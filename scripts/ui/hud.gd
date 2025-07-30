extends Control

signal internal_stamina_updated(current_stamina: float)
signal internal_health_updated(current_health: int)
signal internal_score_updated(current_score: int)

func _on_stamina_updated(current_stamina: float) -> void:
	var processed_stamina := current_stamina * 100.0
	internal_stamina_updated.emit(processed_stamina)


func _on_health_updated(current_health: int) -> void:
	internal_health_updated.emit(current_health)


func _on_score_updated(current_score: int) -> void:
	internal_score_updated.emit(current_score)
