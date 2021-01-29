shader_type canvas_item;

uniform float time_left;
uniform float max_time;
uniform bool active;

const float PI = 3.14159265358979323846;

void fragment() {
	float on = active && (time_left < 0.2 || ((atan(-UV.x, UV.y) + PI) / 2.0 / PI < (time_left / max_time))) ? 1.0/6.0 : 0.0;
	COLOR = vec4(vec3(on), 1.0);
}