shader_type canvas_item;

// this will capture the screen state frozen by the latest BackBufferCopy (there should be just one in Arena)
uniform sampler2D custom_screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    COLOR = texture(custom_screen_texture, SCREEN_UV);
}