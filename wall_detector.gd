extends Area2D

signal hit_wall()
signal leave_wall()

func _on_body_entered(body:Node2D) -> void:
	print('stick')
	hit_wall.emit()


func _on_body_exited(body:Node2D) -> void:
	print('unstick')
	leave_wall.emit()
