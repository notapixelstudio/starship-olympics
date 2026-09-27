shader_type canvas_item;

void fragment() {
    // Sample the text texture
    vec4 text_color = texture(TEXTURE, UV);
    
    COLOR = vec4(1.0, 0.0, 1.0, 1.0);
}