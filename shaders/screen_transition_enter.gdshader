shader_type canvas_item;

// set by gd scripts
uniform float progress = 0.0;

// determines what side to affect
// - 0: top side
// - 1: right side
// - 2: bottom side
// - 3: left side
// does not do anything if any other value is given
uniform int moving_side = 0;

bool pixel_is_filled(vec2 position, float t) {
	switch (moving_side) {
		// move top side
		case 0:
			return (position.y > t);
		// move right side
		case 1:
			return (position.x < t);
		// move bottom side
		case 2:
			return (position.y < t);
		// move left side
		case 3:
			return (position.x > t);
		// default to top side
		default:
			return false;
	}
}

void fragment() {

	vec4 base_color = texture(TEXTURE, UV);

	if (pixel_is_filled(vec2(FRAGCOORD.x, FRAGCOORD.y), progress)) {
		COLOR = base_color;
	}
	else{
		COLOR = vec4(base_color.r, base_color.g, base_color.b, 0.0);
	}
}


