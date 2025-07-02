shader_type canvas_item;

uniform vec4 colors[4]: source_color;
uniform int number_of_colors = 2;
uniform float speed = 1.0;
uniform float stripe_size = 1.0;
uniform float angle = 0.7854; // in radians

void fragment() {
	float w = cos(angle) * UV.x + sin(angle) * SCREEN_UV.y*(-32.0);// - speed * TIME;
	float modulus = floor(mod(w/stripe_size, float(number_of_colors)));
	if (modulus < 0.0001) {
		COLOR *= colors[0];
	} else if (modulus < 1.0001) {
		COLOR *= colors[1];
	} else if (modulus < 2.0001) {
		COLOR *= colors[2];
	} else {
		COLOR *= colors[3];
	}
}