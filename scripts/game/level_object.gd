@tool
class_name LevelObject
## Inherited by all objects used in a level.
extends Node2D


## Must not be blank. Used for instantiating this object
## into the level.
@export var packed_scene_path: String

## Override this function to return properties that the level
## builder should know.
## This dictionary is a `String`-`Variant` pair.
func get_local_properties() -> Dictionary:
	return {}


## Called when this level object is instantiated from a `SavedLevelObject`.
func rehydrate(instance: Node2D) -> void:
	return
