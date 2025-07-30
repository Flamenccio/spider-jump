shader_type canvas_item;

uniform sampler2DArray sprite;
varying flat int sprite_num;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void vertex() {
	float r = rand(vec2(TIME, 0.0));
	r = round(r);
	sprite_num = int(mod(r, 5.0));
}

void fragment() {
	vec4 col = texture(sprite, vec3(UV, float(sprite_num)));
	COLOR = col;
}
