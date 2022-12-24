shader_type canvas_item;
render_mode unshaded;

uniform int blurSize : hint_range(0,20); 

void fragment() 
{
	COLOR = textureLod(TEXTURE, UV, float(blurSize)/10.0); 
}