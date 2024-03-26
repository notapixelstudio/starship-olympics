shader_type canvas_item;

uniform float time_left;
uniform float max_time;
uniform bool active;
uniform float x_direction = 1.0;
uniform vec4 color_on : source_color = vec4(1,1,1,1);
uniform vec4 color_off : source_color = vec4(0,0,0,1);

void fragment() {
	if(active && ((atan(x_direction*UV.x, UV.y) + PI) / 2.0 / PI < (time_left / max_time))) {
		COLOR = color_on;
	}
	else {
		COLOR = color_off;
	}
}