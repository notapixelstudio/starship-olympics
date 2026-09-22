shader_type canvas_item;

uniform float brightness = 1.0;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 screen_sample = texture(screen_texture, SCREEN_UV);
	
	COLOR.rgb = screen_sample.rgb*brightness*COLOR.rgb;
}