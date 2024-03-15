shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if(COLOR.rgb == vec3(0,0,0)) {
		COLOR.rgb = vec3(1,1,1);
	}
	else {
		COLOR = vec4(1,1,1,0);
	}
}