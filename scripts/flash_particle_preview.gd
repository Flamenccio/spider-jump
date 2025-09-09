@tool
extends AnimatedSprite2D

const _FILE_EXTENSION = ".tres"

@export var _file_name: String
@export_dir var _directory: String

## Conditions for the flash particle to expire
@export var _expiration_type: FlashParticle.ExpirationType = FlashParticle.ExpirationType.ANIMATION_END

## If `_expiration_type` is `ANIMATION_LOOP`, the number of loops
## the particles animation must make before expiring
@export_range(1, 100) var _expiration_loops: int = 1

@export_tool_button("Load") var _load_button: Callable = _load_particle
@export_tool_button("Save") var _save_button: Callable = _save_particle

func _load_particle() -> void:
	
	print("flash particle preview: loading particle '{0}'".format({"0": _file_name}))
	var file_path = "{0}/{1}{2}".format({"0": _directory, "1": _file_name, "2": _FILE_EXTENSION})
	var res = ResourceLoader.load(file_path)
	
	if res == null:
		push_error("flash particle preview: no file found '{0}'".format({"0": file_path}))
		return
	
	if res is not SavedFlashParticle:
		push_error("flash particle preview: '{0}' is not a SavedFlashParticle".format({"0": file_path}))
		return
	
	res = res as SavedFlashParticle
	sprite_frames = res.frames
	offset = res.offset
	_expiration_type = res.expiration_type
	_expiration_loops = res.expiration_loops


func _save_particle() -> void:
	
	print("flash particle preview: saving particle '{0}'".format({"0": _file_name}))
	var file_path = "{0}/{1}{2}".format({"0": _directory, "1": _file_name, "2": _FILE_EXTENSION})
	var new_particle = SavedFlashParticle.new()
	new_particle.frames = sprite_frames
	new_particle.offset = offset
	new_particle.particle_name = _file_name
	new_particle.scale = scale
	new_particle.z_index = z_index
	new_particle.expiration_type = _expiration_type
	new_particle.expiration_loops = _expiration_loops
	
	if material is ShaderMaterial:
		new_particle.shader = material
		
	ResourceSaver.save(new_particle, file_path)
