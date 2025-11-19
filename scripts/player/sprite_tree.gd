class_name SpriteTree
extends Node2D

const _DELIMITER = "_"

var _current_branch := ""

## Name of the default active branch.
@export var _default_branch := ""

## Animated sprite to use.
@export var _sprite: AnimatedSprite2D

func _ready() -> void:
	if _sprite == null:
		push_error("sprite tree: sprite is null")
		return
	switch_sprite_branch(_default_branch)


func flip_horizontal(flip: bool) -> void:
	_sprite.flip_h = flip


func flip_vertical(flip: bool) -> void:
	_sprite.flip_v = flip


func switch_sprite_branch(branch: String) -> void:
	branch = branch.to_snake_case()
	var animation_suffix := _get_animation_suffix(_current_branch, _sprite.animation)
	_current_branch = branch
	play_branch_animation(animation_suffix)


func play_branch_animation(animation: String) -> void:

	animation = animation.to_snake_case()
	var target_animation = _make_animation_id(_current_branch, animation)

	if not _sprite.sprite_frames.has_animation(target_animation):
		push_warning("sprite tree: no animation '{0}' exists".format({"0": target_animation}))
		return

	_sprite.play(target_animation)


## Switches to an sprite branch `branch` and plays animation `animation`.
## `branch` is automatically converted to **PascalCase**.
func switch_and_play(branch: String, animation: String) -> void:
	switch_sprite_branch(branch)
	play_branch_animation(animation)


func _make_animation_id(branch: String, animation: String) -> String:
	return "{0}_{1}".format({"0": _current_branch, "1": animation})


func _get_animation_suffix(branch: String, complete_animation: String) -> String:
	return complete_animation.right(-(branch.length() + 1))
