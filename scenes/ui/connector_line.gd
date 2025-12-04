@tool
class_name ConnectorLine
extends Line2D

var _valid_connections: Array[Node]

@export var _connections: Array[Node]:
	set(value):
		_connections = value
		_on_connections_updated()
	get:
		return _connections

@export var _connection_enabled := true


func _on_connections_updated() -> void:
	_valid_connections.clear()
	clear_points()
	for c in _connections:
		if c == null:
			continue
		if c is not Control and c is not Node2D:
			continue
		_valid_connections.append(c)
		add_point(Vector2.ZERO)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not _connection_enabled:
		return
	if _valid_connections.size() <= 1:
		return
	for i in _valid_connections.size():
		var connector = _valid_connections[i]
		set_point_position(i, connector.global_position)


func enable_line(enable: bool) -> void:
	visible = enable
	#_connection_enabled = enable
