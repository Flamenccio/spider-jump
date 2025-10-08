shader_type canvas_item;

const float ghost_alpha = 0.40;
uniform float ghost_frequency = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	float t = TIME * ghost_frequency;
	
	if (round(mod(t, 2.0)) == 0.0){
		COLOR = texture(TEXTURE, UV);
	}
	else{
		vec4 base_color = texture(TEXTURE, UV);
		float alpha = max(base_color.a - ghost_alpha, 0.0);
		COLOR = vec4(base_color.r, base_color.g, base_color.b, alpha);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
