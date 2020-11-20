
shader_type canvas_item;

uniform bool apply = true;
uniform float amount = 1.0;
uniform sampler2D offset_texture : hint_white;

void fragment() {
	vec4 texture_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 color = texture_color;
	
	if (apply == true) {
		float adjusted_amount = amount * texture(offset_texture, SCREEN_UV).r / 100.0;
		color.r = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x + adjusted_amount, SCREEN_UV.y)).r;
		color.g = texture(SCREEN_TEXTURE, SCREEN_UV).g;
		color.b = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x - adjusted_amount, SCREEN_UV.y)).b;
	}
	COLOR = color;
}