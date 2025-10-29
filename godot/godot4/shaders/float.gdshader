shader_type canvas_item;

uniform float amplitude = 10.0;
uniform float frequency = 10.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float offsetY = amplitude * (sin(TIME*frequency)+1.0)/2.0;
	COLOR = texture(TEXTURE, UV + vec2(0.0, offsetY) / 1200.0);
}
