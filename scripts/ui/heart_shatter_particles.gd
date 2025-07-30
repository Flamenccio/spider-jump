extends CPUParticles2D

func spawn_particles(at: Control) -> void:
	if emitting:
		return
	var translation = get_canvas_transform().affine_inverse() * at.get_canvas_transform()
	var pos = translation * (at.global_position + (at.size * at.scale / 2.0))
	print("SIZE: ", at.size)
	global_position = pos
	emitting = true


