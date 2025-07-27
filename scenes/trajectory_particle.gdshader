shader_type canvas_item;

uniform vec2 initial_velocity;
uniform vec2 acceleration;
const float half = 0.50;
const float max_t = 2.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

vec2 point(float t){
	float x = initial_velocity.x * TIME + half * acceleration.x * pow(t, 2.0);
	float y = initial_velocity.y * TIME + half * acceleration.y * pow(t, 2.0);
	return vec2(x, y);
}

vec2 lin(float t){
	return vec2(t, t);
}

void fragment() {
	// Called for every pixel the material is visible on.
	float t = mod(TIME, max_t);
	//print('asdfsadf')
	vec2 l = lin(t);
	COLOR = texture(TEXTURE, vec2(pow(t * UV.x, 1.0 /3.0), UV.y));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
