shader_type canvas_item;

uniform vec4 key_color : source_color;
uniform float multiplier = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if(distance(key_color, COLOR) <= 0.1) {
		COLOR = vec4(1,1,1,multiplier);
	}
	else {
		COLOR = vec4(1,1,1,0);
	}
}