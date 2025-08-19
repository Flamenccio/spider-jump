class_name SpriteTree
extends Node2D

## Name of the default active branch.
## If left blank, the first branch in the array is chosen
@export var _default_branch: String
var _branches: Array[AnimatedSprite2D]
var _active_branch: AnimatedSprite2D

func _ready() -> void:

	# Get branches in children
	var children = get_children()
	for child in children:
		if child is AnimatedSprite2D:
			var new_sprite = child as AnimatedSprite2D
			new_sprite.stop()
			new_sprite.hide()
			_branches.append(new_sprite)


	if _branches.size() == 0:
		push_error('sprite tree: no sprite branches!')
		return

	# Set default branch
	# Set active branch to first
	if _default_branch == null or _default_branch == '':
		_active_branch = _branches[0]
	# Set active branch to _default_branch
	else:
		switch_sprite_branch(_default_branch)


## Switches the current active branch to `to`. Automatically converted to **PascalCase** to match node-naming conventions.
func switch_sprite_branch(to: String) -> void:
	to = to.to_pascal_case()
	var index = _branches.find_custom(func(a: AnimatedSprite2D): return a.name == to)
	if index < 0:
		push_error('sprite tree: no sprite branches with name "{0}"'.format({'0': to}))
		return
	var old = _active_branch
	_active_branch = _branches[index]
	var old_animation = ''
	if old != null:
		old_animation = _active_branch.animation
		old.stop()
		old.hide()
	_active_branch.show()
	if _active_branch.sprite_frames.has_animation(old_animation) and old_animation != '':
		_active_branch.play(old_animation)


## Plays an animation on the current branch
func play_branch_animation(animation: String) -> void:
	if _active_branch == null:
		push_error('sprite tree: _active_branch is null!')
		return
	_active_branch.play(animation)


## Switches to an sprite branch `branch` and plays animation `animation`.
## `branch` is automatically converted to **PascalCase**.
func switch_and_play(branch: String, animation: String) -> void:
	switch_sprite_branch(branch)
	play_branch_animation(animation)

