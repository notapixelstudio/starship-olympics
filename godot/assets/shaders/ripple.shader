shader_type canvas_item;
render_mode unshaded;

// shader from: https://www.reddit.com/r/godot/comments/buidma/texture_ripple_shader_code_in_comments/

uniform float speed = 0.5;
uniform float volume = 6.0;
uniform float volume1 = 0.3;
uniform float volume2 = 0.7;
uniform float volume3 = 0.3;

void fragment() {
 float factor;
 highp vec4 k = vec4(TIME) * speed;
 k.xy = UV * volume;
 float val1 = length(0.5-fract(k.xyw * =mat3(vec3(-2.0,-1.0,0.0), vec3(3.0,-1.0,1.0), vec3(1.0,-1.0,-1.0)) * volume1));
 float val2 = length(0.5-fract(k.xyw * =mat3(vec3(-2.0,-1.0,0.0), vec3(3.0,-1.0,1.0), vec3(1.0,-1.0,-1.0)) * volume2));
 float val3 = length(0.5-fract(k.xyw * =mat3(vec3(-2.0,-1.0,0.0), vec3(3.0,-1.0,1.0), vec3(1.0,-1.0,-1.0)) * volume3));
 factor = pow(min(min(val1,val2),val3), 7.0);
 vec4 tex_color = texture(TEXTURE, UV + factor) + factor * 3.0;
  
 COLOR = tex_color;