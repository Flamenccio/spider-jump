shader_type canvas_item;

uniform sampler2D dot_tex : source_color;
uniform float dot_spacing = 15.0;
uniform float dot_size = 15.0;

void fragment() {
	vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE;

	uv = round(uv * dot_size) / dot_size;
	float dist = sqrt(pow(uv.x, 2.0) + pow(uv.y, 2.0));

	float d = mod(dist, dot_spacing);
	if (d < 1.0){
		vec4 color = texture(dot_tex, uv);
		COLOR = color;
	}
	else{
		discard;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
