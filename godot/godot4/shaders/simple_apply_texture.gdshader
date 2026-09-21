shader_type canvas_item;

uniform sampler2D main_texture : hint_default_white;

void fragment() {
    COLOR = texture(main_texture, UV);
}