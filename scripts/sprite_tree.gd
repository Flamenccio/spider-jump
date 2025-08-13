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


## Switches the current active branch to `to`. **Case insensitive**!
func switch_sprite_branch(to: String) -> void:
	var index = _branches.find_custom(func(a: AnimatedSprite2D): return a.name.to_lower() == to.to_lower())
	if index < 0:
		push_error('sprite tree: no sprite branches with name "{0}"'.format({'0': to}))
		return
	var old = _active_branch
	_active_branch = _branches[index]
	if old != null:
		old.stop()
		old.hide()
	_active_branch.show()


## Plays an animation on the current branch
func play_branch_animation(animation: String) -> void:
	if _active_branch == null:
		push_error('sprite tree: _active_branch is null!')
		return
	_active_branch.play(animation)


## Switches to an sprite branch `branch` and plays animation `animation`.
## `branch` is **case insensitive**.
func switch_and_play(branch: String, animation: String) -> void:
	switch_sprite_branch(branch)
	play_branch_animation(animation)

