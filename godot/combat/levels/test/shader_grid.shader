shader_type canvas_item;

uniform vec2 size = vec2(1000.0, 1000.0);
uniform float cell_size = 100.0;
uniform float stroke;
uniform vec2 well;
uniform bool triangular = false;

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
	t = fract(t*0.25)*4.0;
	float d = distance(p, well+size/2.0);
	return amplitude*cos(d/80.0-t*5.0)/exp(d*0.003+t*2.0); // d*0.003 (std), 0.001 (big), 0.005 (small)
}

vec3 create_point(int row, int col, float amplitude, float t){
	vec3 p = vec3(float(col)*cell_size, float(row)*cell_size, 0.0);
	p.x += triangular && row%2==1 ? cell_size*0.5 : 0.0; // squiggly
	//float d = distance(p.xy, well)/50.0;
	//p.x += amplitude*sin(d);
	//p.z += amplitude*cos(d-t*8.0)/exp(d/4.0);
	//p.z += 8.0*amplitude*sin(d-t*3.0)/exp(d*0.5);
	p.z += get_z(amplitude, p.xy, t);
	return p;
}

void fragment(){
	float amplitude = cell_size*6.0;
	
	// Tile the space
	vec2 uv = UV*size/cell_size + vec2(0.5,0.5);
    ivec2 i_uv = ivec2(floor(uv));
    vec2 f_uv = fract(uv);
	
	float f = 1.0;
	vec3 p1n;
	vec3 p2n;
	
	for (int col = i_uv.x-1; col <= i_uv.x+1; col++) {
		for (int row = i_uv.y-1; row <= i_uv.y+1; row++) {
			p1n = create_point(row, col, amplitude, TIME);
			p1n.y += p1n.z;
			
			// right
			p2n = create_point(row, col+1, amplitude, TIME);
			p2n.y += p2n.z;
			f = min(f, distance_from_segment(p1n.xy/size, p2n.xy/size, UV));
			
			// left
			p2n = create_point(row, col-1, amplitude, TIME);
			p2n.y += p2n.z;
			f = min(f, distance_from_segment(p1n.xy/size, p2n.xy/size, UV));
			
			if(triangular){
				// /
				p2n = create_point(row+1, col+row%2, amplitude, TIME);
				p2n.y += p2n.z;
				f = min(f, distance_from_segment(p1n.xy/size, p2n.xy/size, UV));
				
				// \
				p1n = create_point(row, col+1, amplitude, TIME);
				p1n.y += p1n.z;
				p2n = create_point(row+1, col+row%2, amplitude, TIME);
				p2n.y += p2n.z;
				f = min(f, distance_from_segment(p1n.xy/size, p2n.xy/size, UV));
			}
			else {
				// down
				p2n = create_point(row+1, col, amplitude, TIME);
				p2n.y += p2n.z;
				f = min(f, distance_from_segment(p1n.xy/size, p2n.xy/size, UV));
				
				// up
				p2n = create_point(row-1, col, amplitude, TIME);
				p2n.y += p2n.z;
				f = min(f, distance_from_segment(p1n.xy/size, p2n.xy/size, UV));
			}
		}
	}
	float c = 1.0-step(stroke/2.0/size.x, f);
	float a = 1.0 - clamp(get_z(amplitude/cell_size, UV*size, TIME)*0.5, 0.0, 1.0);
	COLOR = vec4( vec3(c), min(a, c) );
	//COLOR = vec4(0.0, 0.25*step(0.95, max(f_uv.x,f_uv.y)), 0.0, 1.0) + vec4(vec3( 1.0-step(stroke/2.0/scale, f)), 0.0);
}