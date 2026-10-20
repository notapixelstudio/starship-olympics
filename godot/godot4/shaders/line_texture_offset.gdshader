shader_type canvas_item;

uniform float texture_offset = 0.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, vec2(UV.x + texture_offset, UV.y));
    COLOR = tex_color * COLOR;
}