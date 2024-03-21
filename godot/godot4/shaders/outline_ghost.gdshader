shader_type canvas_item;

uniform vec3 key_color : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if(COLOR.rgb == key_color) {
		COLOR.rgb = vec3(1,1,1);
	}
	else {
		COLOR = vec4(1,1,1,0);
	}
}