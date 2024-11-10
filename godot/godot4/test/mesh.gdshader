shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX += vec2(cos(TIME)*VERTEX.y, 0);
}

void fragment() {
	// Called for every pixel the material is visible on.
	if(UV.x < 2.0 || UV.x > 198.0 || UV.y < 2.0 || UV.y > 198.0) {
		COLOR = vec4(0.0,0.0,0.0,1.0);
	}
}