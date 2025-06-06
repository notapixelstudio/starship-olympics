shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

varying flat vec4 modulate;

//
uniform float boost : hint_range(1.0, 2.0, 0.01) = float(1.2);
uniform float grille_opacity : hint_range(0.0, 1.0, 0.01) = float(0.85);
uniform float scanlines_opacity : hint_range(0.0, 1.0, 0.01) = float(0.95);
uniform float vignette_opacity : hint_range(0.1, 0.5, 0.01) = float(0.2);
uniform float scanlines_speed : hint_range(0.0, 5.0, 0.1) = float(1.0);
uniform bool show_grille = true;
uniform bool show_scanlines = true;
uniform bool show_vignette = true;
uniform bool show_curvature = true; // Curvature works best on stretch mode 2d.
uniform vec2 screen_size = vec2(320.0, 180.0);
uniform float aberration_amount : hint_range(0.0, 10.0, 0.01) = float(0.0);
uniform bool move_aberration = false;
uniform float aberration_speed : hint_range(0.01, 10.0, 0.01) = float(1.0);
uniform float pincushion : hint_range(0.01, 10.0, 0.01) = float(1.0);

vec2 CRTCurveUV(vec2 uv) {
	if(show_curvature) {
		uv = uv * 2.0 - 1.0;
		vec2 offset = abs(uv.yx) / vec2(9.0, 6.0) * pincushion;
		uv = uv + uv * offset * offset;
		uv = uv * 0.5 + 0.5;
	}
	return uv;
}

void DrawVignette(inout vec4 color, vec2 uv) {
	if(show_vignette) {
		float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
		vignette = clamp(pow((screen_size.x / 4.0) * vignette, vignette_opacity), 0.0, 1.0);
		color *= vignette;
	} else {
		return;
	}
}

void DrawScanline(inout vec4 color, vec2 uv, float time) {
	float scanline = clamp((scanlines_opacity - 0.05) + 0.05 * sin(3.1415926535 * (uv.y + 0.008 * time) * screen_size.y), 0.0, 1.0);
	float grille = (grille_opacity - 0.15) + 0.15 * clamp(1.5 * sin(3.1415926535 * uv.x * screen_size.x), 0.0, 1.0);

	if (show_scanlines) {
		color *= scanline;
	}

	if (show_grille) {
		color *= grille;
	}

	color *= boost;
}

void vertex() {
	modulate = COLOR;
}

//void fragment() {
	//vec2 screen_crtUV = CRTCurveUV(SCREEN_UV);
	//vec4 color = texture(SCREEN_TEXTURE, screen_crtUV);
//
//
//
	//if (color.a > 0.0001) {
		//color.rgb /= color.a;
//
	//}
//
	//// aberration
	//float adjusted_amount = aberration_amount / screen_size.x;
	//color.r = texture(SCREEN_TEXTURE, vec2(screen_crtUV.x + adjusted_amount, screen_crtUV.y)).r;
	//color.g = texture(SCREEN_TEXTURE, screen_crtUV).g;
	//color.b = texture(SCREEN_TEXTURE, vec2(screen_crtUV.x - adjusted_amount, screen_crtUV.y)).b;
//
//
	//COLOR *= color * boost;
//}

void fragment() {
	vec2 screen_crtUV = CRTCurveUV(UV);
	vec4 color = textureLod(TEXTURE, screen_crtUV, 0.0).rgba;
	
	if (color.a > 0.01) {
		color.rgb /= color.a;
		COLOR *= color;
		
		if (aberration_amount > 0.0) {
			float adjusted_amount = aberration_amount / screen_size.x;
			
			if (move_aberration == true) {
				adjusted_amount = (aberration_amount / screen_size.x) * cos((2.0 * 3.14159265359) * (TIME / aberration_speed));
			}
			
			color.r = texture(TEXTURE, vec2(screen_crtUV.x + adjusted_amount, screen_crtUV.y)).r;
			color.g = texture(TEXTURE, screen_crtUV).g;
			color.b = texture(TEXTURE, vec2(screen_crtUV.x - adjusted_amount, screen_crtUV.y)).b;
		}
		
		vec2 crtUV = CRTCurveUV(SCREEN_UV);
		if (crtUV.x < 0.0 || crtUV.x > 1.0 || crtUV.y < 0.0 || crtUV.y > 1.0) {
			color = vec4(0.0, 0.0, 0.0, 1.0);
		}
		
		DrawVignette(color, crtUV);
		DrawScanline(color, crtUV, -TIME * scanlines_speed);
		
		COLOR = color * modulate;
	}
	else {
		COLOR = vec4(0.0,0.0,0.0,0.0);
	}
}