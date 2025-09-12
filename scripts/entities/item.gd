@tool
class_name Item
extends StaticBody2D

@export var _debug_item: GenericItem
@export var _item_id: String

## Replaces the item with the `GenericItem` supplied via `_debug_item`
@export_tool_button("Replace item") var _replace_item_button: Callable = _replace_item

var item_id: String:
	get:
		return _item_id
	set(value):
		_item_id = value


func _ready() -> void:
	_play_default_animations()


func remove_powerup() -> void:

	if Engine.is_editor_hint():
		return

	var yumfly_instance = load("res://resources/items/yumfly.tres").instantiate_item()
	yumfly_instance.global_position = global_position
	get_parent().add_child(yumfly_instance)
	queue_free()


func _play_default_animations() -> void:
	if Engine.is_editor_hint():
		return
	var children = get_children()
	for child in children:
		if child is AnimatedSprite2D:
			var anim = child as AnimatedSprite2D
			var default_animation = anim.sprite_frames.get_animation_names()[0]
			anim.play(default_animation)


func _replace_item() -> void:

	if not Engine.is_editor_hint():
		return
	if _debug_item == null:
		return
	for child in get_children():
		child.free()

	var instance = _debug_item.instantiate_item()
	var instance_children = instance.get_children()
	item_id = _debug_item.item_id

	for instance_child in instance_children:
		call_deferred("_reparent_debug_child", instance_child)

	instance.queue_free()
	self.name = _debug_item.item_id.to_pascal_case()


func _reparent_debug_child(child: Node) -> void:
	if not Engine.is_editor_hint():
		return
	child.reparent(self)
	child.owner = get_tree().edited_scene_root
	if child is Node2D:
		child.position = Vector2.ZERO
