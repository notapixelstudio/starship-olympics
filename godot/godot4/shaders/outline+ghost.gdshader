shader_type canvas_item;

uniform vec3 key_color : source_color;
uniform vec3 target_color : source_color = vec3(1,1,1);
uniform bool ghost = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if(distance(COLOR.rgb, key_color) <= 0.1) {
		COLOR.rgb = target_color;
	}
	else if(ghost){
		COLOR = vec4(1,1,1,0);
	}
}