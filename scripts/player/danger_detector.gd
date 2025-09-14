extends Area2D

var _shapes: Array[CollisionShape2D]

func _ready() -> void:
	var children = get_children()
	for child in children:
		if child is CollisionShape2D:
			_shapes.append(child as CollisionShape2D)


func disable_detector() -> void:
	set_detecting(false)


func enable_detector() -> void:
	set_detecting(true)


func set_detecting(detecting: bool) -> void:
	for shape: CollisionShape2D in _shapes:
		shape.set_deferred('disabled', not detecting)
