shader_type canvas_item;

uniform lowp vec2 size = vec2(1000.0, 1000.0);
uniform lowp float cell_size = 100.0;
uniform lowp float stroke;
uniform lowp vec2 well;

lowp float distance_from_segment(lowp vec2 v, lowp vec2 w, lowp vec2 p){
	lowp float l = distance(v, w);
	//if (l <= 0.01)
	//	return distance(p, v);   // v == w case
		
	// Consider the line extending the segment, parameterized as v + t (w - v).
	// We find projection of point p onto the line.
	// It falls where t = [(p-v) . (w-v)] / |w-v|^2
	// We clamp t from [0,1] to handle points outside the segment vw.
	lowp float t = clamp(dot(p - v, w - v) / (l*l), 0, 1);
	return distance(p, v + t * (w - v)); // Projection falls on the segment
}

lowp float get_z(lowp float amplitude, lowp vec2 p, float t){
	t = fract(t*0.25)*4.0;
	lowp float d = distance(p, well+size/2.0);
	return amplitude*cos(d/80.0-t*5.0)/exp(d*0.003+t*2.0); // d*0.003 (std), 0.001 (big), 0.005 (small)
}

lowp vec3 create_point(int row, int col, lowp float amplitude, float t){
	lowp vec3 p = vec3(float(col)*cell_size, float(row)*cell_size, 0.0);
	p.z += get_z(amplitude, p.xy, t);
	return p;
}

void fragment(){
	lowp float amplitude = cell_size*6.0;
	
	// Tile the space
	lowp vec2 uv = UV*size/cell_size + vec2(0.5,0.5);
    lowp ivec2 i_uv = ivec2(floor(uv));
    lowp vec2 f_uv = fract(uv);
	
	lowp float f = 1.0;
	lowp vec3 p1n;
	lowp vec3 p2n;
	
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
	lowp float c = 1.0-step(stroke/2.0/size.x, f);
	lowp float a = 1.0 - clamp(get_z(amplitude/cell_size, UV*size, TIME)*0.5, 0.0, 1.0);
	COLOR = vec4( vec3(c), min(a, c) );
	//COLOR = vec4(0.0, 0.25*step(0.95, max(f_uv.x,f_uv.y)), 0.0, 1.0) + vec4(vec3( 1.0-step(stroke/2.0/scale, f)), 0.0);
}