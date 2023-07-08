
shader_type canvas_item;

uniform bool apply = true;
uniform float amount = 1.0;
uniform sampler2D offset_texture : hint_default_white;

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	vec4 color = texture_color;
	
	if (apply == true) {
		float adjusted_amount = amount * texture(offset_texture, UV).r / 100.0;
		color.r = texture(TEXTURE, vec2(UV.x + adjusted_amount, UV.y)).r;
		color.g = texture(TEXTURE, UV).g;
		color.b = texture(TEXTURE, vec2(UV.x - adjusted_amount, UV.y)).b;
	}
	COLOR = color;
}