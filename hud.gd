extends Control

signal internal_stamina_updated(current_stamina: float)

func _on_stamina_updated(current_stamina: float) -> void:
	var processed_stamina := current_stamina * 100.0
	internal_stamina_updated.emit(processed_stamina)
