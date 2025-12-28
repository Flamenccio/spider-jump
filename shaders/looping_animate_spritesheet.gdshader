shader_type canvas_item;

uniform int cols: hint_range(1, 128) = 1;
uniform int rows: hint_range(1, 128) = 1;
uniform float fps: hint_range(1, 120) = 24;
uniform sampler2D tex: filter_nearest;
uniform bool animate = true;

void fragment() {
	
	if (animate){
		
		int total_frames = cols * rows;
		float frame_duration = 1.0 / fps;
		int current_frame = int(mod(
			TIME / frame_duration, float(total_frames))
		);
		vec2 frame_size = vec2(1.0 / float(cols), 1.0 / float(rows));
		
		int current_col = current_frame % cols;
		int current_row = current_frame / cols;
		
		vec2 frame_offset = vec2(
			frame_size.x * float(current_col), 
			frame_size.y * float(current_row)
		);
		
		// Position of the fragment coordinate within the
		// animation frame to sample from
		vec2 frame_position = vec2(
			UV.x * float(frame_size.x), 
			UV.y * float(frame_size.y)
		);
		
		COLOR = texture(tex, frame_position + frame_offset);
	}
	else{
		COLOR = vec4(0, 0, 0, 0);
	}
}
