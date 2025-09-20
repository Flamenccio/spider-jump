shader_type canvas_item;

const float fill_time_seconds = 2.0;
const float pixel_factor = 128.0;

// set by gd scripts
uniform float start_time = 0.0;
uniform int direction = 1;

void fragment() {

	float progress = (TIME - start_time) / fill_time_seconds;
	progress = clamp(progress, 0.0, 1.0);
	vec4 base_color = texture(TEXTURE, UV);

	bool exit = (direction == -1 && UV.y < progress);
	bool enter = (direction == 1 && UV.y > progress);

	if ((exit && !enter) || (!exit && enter)) {
		COLOR = vec4(base_color.r, base_color.g, base_color.b, 0.0);
	}
	else {
		COLOR = base_color;
	}
}
