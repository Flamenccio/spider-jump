shader_type canvas_item;

uniform bool ghost = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {

	if (ghost){
		vec4 previous_color = texture(TEXTURE, UV);
		vec4 col = vec4(previous_color.r, previous_color.g, previous_color.b, max(previous_color.a - 0.40, 0.0));
		COLOR = col;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
