extends Label

var shader: ShaderMaterial

func _ready() -> void:
	shader = material as ShaderMaterial


func set_shader_param(property: String, value: Variant) -> void:
	shader.set_shader_parameter(property, value)
