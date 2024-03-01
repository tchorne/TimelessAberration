shader_type spatial;

render_mode unshaded;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
instance uniform bool lines = false;
instance uniform bool targetable = false;
instance uniform float linethickness = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO.rg = SCREEN_UV*0.25+vec2(0.25, 0.25);
	if (!targetable) ALBEDO.rgb *= 0.1;
	float band_thickness = 0.5;
	float phase = TIME;
	if (lines){
		if (fract(fract(SCREEN_UV.x*100.0+SCREEN_UV.y*50.0)+phase) < band_thickness){
			ALBEDO.rgb -= vec3(0.1,0.4,0.4);
		} 
	}
	if (linethickness < 1.0){
		if (fract(fract(SCREEN_UV.x*100.0+SCREEN_UV.y*50.0)+phase) > linethickness){
			discard;
		} 
	}
	
}

void light() {
	// Called for every pixel for every light affecting the material.
}
