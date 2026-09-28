shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.502, 0.749, 1.0, 0.059);
uniform float glow_inner_edge : hint_range(0.0, 1.0) = 0.7;
uniform float glow_softness : hint_range(0.01, 1.0) = 0.5;
uniform float grille_alpha : hint_range(0.0, 1.0) = 0.8;

void fragment() {
    float dist = texture(TEXTURE, UV).a;
    
    // needs MSDF support to be set on font import with a big msdf pixel range
    float glow_alpha = smoothstep(glow_inner_edge - glow_softness, glow_inner_edge, dist);
    
	if(COLOR.a < 1.0) {
		COLOR = vec4(glow_color.rgb, glow_color.a * glow_alpha);
	}
	COLOR = COLOR * (mod(UV.y * 150.0, 0.8)  < 0.4 ? grille_alpha : 1.00);
}