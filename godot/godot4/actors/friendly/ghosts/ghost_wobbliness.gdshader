shader_type canvas_item;

// Direction of the wobble (+1 = LEFT, -1 = RIGHT)
uniform float direction : hint_range(-1.0, 1.0, 2.0) = 1.0;
uniform float speed : hint_range(0.0, 20.0) = 8.0;
// Number of wave bumps across the bottom
uniform float frequency : hint_range(0.0, 50.0) = 15.0;
// Height of the wave cuts
uniform float amplitude : hint_range(0.0, 0.5) = 0.15;

void fragment() {
	// Start from bottom and go up to compute the starting threshold
	float wobble_threshold = 1.0 - amplitude;
	
	// Get the base color of the texture 
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Calculate the wave's baseline height at this specific horizontal (X) position
    // We add 1.0 and multiply by 0.5 to keep the sine wave output purely positive (between 0.0 and 1.0)
    float wave = (sin(TIME * direction * speed + UV.x * frequency) + 1.0) * 0.5;
    
    // Scale the wave height by our amplitude, and offset it to start at the threshold
    float wave_cutoff = wobble_threshold + (wave * amplitude);
    
    // If the current vertical pixel (UV.y) is lower than the wave line, set it to transparent
    if (UV.y > wave_cutoff) {
        tex_color.a = 0.0;
    }
    
    // Output the final color, keeping modulate
    COLOR *= tex_color;
}