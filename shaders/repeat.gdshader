shader_type canvas_item;

uniform float tiles_x = 1.0;
uniform float tiles_y = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 scaled_uv = vec2(UV.x * tiles_x, UV.y * tiles_y);
	vec2 tiled_uv = fract(scaled_uv);
	COLOR = texture(TEXTURE, tiled_uv);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
