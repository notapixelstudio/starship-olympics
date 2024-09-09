shader_type canvas_item;
render_mode unshaded;

uniform float pincushion : hint_range(0.01, 10.0, 0.01) = float(1.0);

vec2 CRTCurveUV(vec2 uv) {
	uv = uv * 2.0 - 1.0;
	vec2 offset = abs(uv.yx) / vec2(9.0, 6.0) * pincushion;
	uv = uv + uv * offset * offset;
	uv = uv * 0.5 + 0.5;
	return uv;
}

void fragment() {
	vec2 screen_crtUV = CRTCurveUV(SCREEN_UV);
	if (screen_crtUV.x < 0.0 || screen_crtUV.x > 1.0 || screen_crtUV.y < 0.0 || screen_crtUV.y > 1.0) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	}
}