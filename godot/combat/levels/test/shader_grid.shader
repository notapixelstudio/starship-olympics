shader_type canvas_item;

const float scale = 1000.0;
uniform float stroke;
uniform vec2 well;

float distance_from_segment(vec2 v, vec2 w, vec2 p){
	float l = distance(v, w);
	//if (l <= 0.01)
	//	return distance(p, v);   // v == w case
		
	// Consider the line extending the segment, parameterized as v + t (w - v).
	// We find projection of point p onto the line.
	// It falls where t = [(p-v) . (w-v)] / |w-v|^2
	// We clamp t from [0,1] to handle points outside the segment vw.
	float t = clamp(dot(p - v, w - v) / (l*l), 0, 1);
	return distance(p, v + t * (w - v)); // Projection falls on the segment
}

float get_z(float amplitude, vec2 p, float t){
	t = fract(t*0.25);
	float d = distance(p, well)/50.0;
	return amplitude*cos(d-t*20.0)/exp(d*0.4+t*16.0);
}

vec3 create_point(int row, int col, float cell_size, float amplitude, float t){
	vec3 p = vec3(float(col)*cell_size, float(row)*cell_size, 0.0);
	//float d = distance(p.xy, well)/50.0;
	//p.x += amplitude*sin(d);
	//p.z += amplitude*cos(d-t*8.0)/exp(d/4.0);
	//p.z += 8.0*amplitude*sin(d-t*3.0)/exp(d*0.5);
	p.z += get_z(amplitude, p.xy, t);
	return p;
}

void fragment(){
	const float cell_size = 50.0;
	float amplitude = cell_size*7.0;
	
	// Tile the space
	vec2 uv = UV*scale/cell_size + vec2(0.5,0.5);
    ivec2 i_uv = ivec2(floor(uv));
    vec2 f_uv = fract(uv);
	
	float f = 1.0;
	vec3 p1n;
	vec3 p2n;

	// well field
	float d = distance(UV, well/scale);
	
	for (int col = i_uv.x-2; col <= i_uv.x+2; col++) {
		for (int row = i_uv.y-2; row <= i_uv.y+2; row++) {
			p1n = create_point(row, col, cell_size, amplitude, TIME);
			p1n.y += p1n.z;
			
			// right
			p2n = create_point(row, col+1, cell_size, amplitude, TIME);
			p2n.y += p2n.z;
			f = min(f, distance_from_segment(p1n.xy/scale, p2n.xy/scale, UV));
			
			// down
			p2n = create_point(row+1, col, cell_size, amplitude, TIME);
			p2n.y += p2n.z;
			f = min(f, distance_from_segment(p1n.xy/scale, p2n.xy/scale, UV));
		}
	}
	float c = 1.0-step(stroke/2.0/scale, f);
	float a = clamp(1.0-log(abs(get_z(amplitude, UV*scale, TIME))), 0.0, c);
	COLOR = vec4( vec3(c), c );
	//COLOR = vec4(0.0, 0.25*step(0.95, max(f_uv.x,f_uv.y)), 0.0, 1.0) + vec4(vec3( 1.0-step(stroke/2.0/scale, f)), 0.0);
}