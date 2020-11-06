shader_type canvas_item;

const float size = 1000.0;
uniform float cell_size = 200.0;
uniform float stroke = 10.0;
uniform float time;
uniform sampler2D wells_texture;
uniform bool triangular = false;
uniform vec4 fg_color;
uniform vec4 bg_color;

vec3 get_well(int index){
	return texelFetch(wells_texture, ivec2(index, 0), 0).xyz;
}

float distance_from_segment(vec2 v, vec2 w, vec2 p){
	float l = distance(v, w);
	//if (l <= 0.01)
	//	return distance(p, v);   // v == w case
		
	// Consider the line extending the segment, parameterized as v + x (w - v).
	// We find projection of point p onto the line.
	// It falls where x = [(p-v) . (w-v)] / |w-v|^2
	// We clamp x from [0,1] to handle points outside the segment vw.
	float x = clamp(dot(p - v, w - v) / (l*l), 0, 1);
	return distance(p, v + x * (w - v)); // Projection falls on the segment
}

float get_well_strength(vec3 well, float amplitude, vec2 p){
	float t = time - well.z;
	if(t <= 0.0){
		return 0.0;
	}
	float d = distance(p, well.xy);
	return amplitude*cos(d/80.0-t*5.0)/exp(d*0.003+t*2.0); // d*0.003 (std), 0.001 (big), 0.005 (small)
}

float get_z(float amplitude, vec2 p){
	float strength = 0.0;
	for(int index=0; index<textureSize(wells_texture, 0).x; index++){
		strength = max(strength, get_well_strength(get_well(index), amplitude, p));
	}
	
	return strength;
}

vec3 create_point(int row, int col, float amplitude){
	vec3 p = vec3(float(col)*cell_size, float(row)*cell_size, 0.0);
	p.x += triangular && row%2==1 ? cell_size*0.5 : 0.0; // squiggly
	//float d = distance(p.xy, well)/50.0;
	//p.x += amplitude*sin(d);
	//p.z += amplitude*cos(d-t*8.0)/exp(d/4.0);
	//p.z += 8.0*amplitude*sin(d-t*3.0)/exp(d*0.5);
	//p.z += get_z(amplitude, p.xy);
	return p;
}

void fragment(){
	/*float amplitude = 2.0*cell_size;
	
	// Tile the space
	vec2 uv = UV*size/cell_size + vec2(0.5,0.5);
    ivec2 i_uv = ivec2(floor(uv));
    vec2 f_uv = fract(uv);
	
	float f = 1.0;
	vec3 p1n;
	vec3 p2n;
	
	for (int col = i_uv.x-1; col <= i_uv.x+1; col++) {
		for (int row = i_uv.y-1; row <= i_uv.y+1; row++) {
			p1n = create_point(row, col, amplitude);
			//p1n.y += p1n.z;
			
			// right
			p2n = create_point(row, col+1, amplitude);
			//p2n.y += p2n.z;
			f = min(f, distance_from_segment(p1n.xy/size, p2n.xy/size, UV));
			
			// left
			p2n = create_point(row, col-1, amplitude);
			//p2n.y += p2n.z;
			f = min(f, distance_from_segment(p1n.xy/size, p2n.xy/size, UV));
			
			if(triangular){
				// /
				p2n = create_point(row+1, col+row%2, amplitude);
				//p2n.y += p2n.z;
				f = min(f, distance_from_segment(p1n.xy/size, p2n.xy/size, UV));
				
				// \
				p1n = create_point(row, col+1, amplitude);
				//p1n.y += p1n.z;
				p2n = create_point(row+1, col+row%2, amplitude);
				//p2n.y += p2n.z;
				f = min(f, distance_from_segment(p1n.xy/size, p2n.xy/size, UV));
			}
			else {
				// down
				p2n = create_point(row+1, col, amplitude);
				//p2n.y += p2n.z;
				f = min(f, distance_from_segment(p1n.xy/size, p2n.xy/size, UV));
				
				// up
				p2n = create_point(row-1, col, amplitude);
				//p2n.y += p2n.z;
				f = min(f, distance_from_segment(p1n.xy/size, p2n.xy/size, UV));
			}
		}
	}
	float c = 1.0-smoothstep(0.0, stroke/2.0/size, f);
	float a = 1.0 - clamp(get_z(amplitude/cell_size, UV*size)*0.5, 0.0, 1.0);
	COLOR = vec4( vec3(c), 1.0 );
	//COLOR = vec4(0.0, 0.25*step(0.95, max(f_uv.x,f_uv.y)), 0.0, 1.0) + vec4(vec3( 1.0-step(stroke/2.0/size, f)), 0.0);
	*/
	//vec2 displacement_uv = UV + displacement.xy * uv_displace_amount;
	//float t = mod(TIME, 8.0);
	//vec2 v = vec2(0.5,0.5);
	//float w = sin(time*4.0);
	//float d = smoothstep(-50.0-50.0*w,32.0,dot(UV,UV));
	//COLOR = texture(TEXTURE, UV*d);
	float value = 1.0 - texture(TEXTURE, UV).a;
	COLOR = vec4(mix(fg_color.rgb, bg_color.rgb, value), 1.0);
}