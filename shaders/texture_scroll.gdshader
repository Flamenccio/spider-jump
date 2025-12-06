shader_type canvas_item;

uniform float speed_x = 0.0;
uniform float speed_y = 0.0;

void fragment() {
	COLOR = texture(TEXTURE, vec2(UV.x + TIME * speed_x, UV.y + TIME * speed_y));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
