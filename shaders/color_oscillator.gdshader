shader_type canvas_item;

uniform bool oscillate_active;
uniform vec4 tint;
uniform float oscillate_speed;

float lerp(float a, float b, float t){
	return (a * t) + (b * (1.0 - t));
}

void fragment() {
	if (oscillate_active){
		vec4 base_color = texture(TEXTURE, UV);
		float speed = max(0.0001, oscillate_speed);
		float t = sin(mod(speed * TIME, 2.0 * PI));
		float r = lerp(tint.r, base_color.r, t);
		float g = lerp(tint.g, base_color.g, t);
		float b = lerp(tint.b, base_color.b, t);
	
		vec4 color = vec4(r, g, b, base_color.a);
		COLOR = color;
	}
}
