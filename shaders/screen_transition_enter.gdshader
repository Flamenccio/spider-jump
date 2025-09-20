shader_type canvas_item;

// set by gd scripts
uniform float progress = 0.0;

// if FALSE, moves bottom side
// if TRUE, moves top side
uniform bool move_top_side = false;

void fragment() {

	float screen_y = FRAGCOORD.y;
	vec4 base_color = texture(TEXTURE, UV);
	float t = progress;

	if ((screen_y > t && !move_top_side) || (screen_y < t && move_top_side)) {
		COLOR = vec4(base_color.r, base_color.g, base_color.b, 0.0);
	}
	else{
		COLOR = base_color;
	}
}
