extends Area2D

signal player_entered()

# Determines what elevation the trigger will travel to next
var _elevation_queue: Array[float]

func enqueue_elevation(elevation: float) -> void:
	_elevation_queue.push_back(elevation)


func travel_to_next_elevation() -> void:

	if _elevation_queue.size() == 0:
		print('level spawn trigger: no more elevations left!')
		return

	var next = _elevation_queue.pop_front()
	global_position = Vector2(0.0, next)


## Immediately goes to an elevation specified.
## Does not dequeue the elevation queue.
func go_to_elevation(elevation: float) -> void:
	global_position = Vector2(0.0, elevation)


func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		player_entered.emit()
		travel_to_next_elevation()
