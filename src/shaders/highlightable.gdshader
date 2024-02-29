shader_type spatial;

render_mode unshaded;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
instance uniform bool lines = false;
instance uniform bool player = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO.rg = SCREEN_UV;
	float band_thickness = 0.5;
	float phase = TIME;
	if (lines){
		if (fract(fract(SCREEN_UV.x*100.0+SCREEN_UV.y*50.0)+phase) < band_thickness){
			ALBEDO.rgb -= vec3(0.1,0.1,0.1);
		} 
	}
	if (player && fract(fract(SCREEN_UV.x*100.0+SCREEN_UV.y*50.0)+phase) < band_thickness) discard;
	
}

void light() {
	// Called for every pixel for every light affecting the material.
}
