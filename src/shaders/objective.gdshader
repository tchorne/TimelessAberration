shader_type spatial;

render_mode unshaded, shadows_disabled, depth_test_disabled;

uniform vec4 color : source_color;
uniform float t;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//vec3 normal2 = refract(NORMAL.xyz, vec3(0,0,1), SCREEN_UV.x);
	float d = dot(NORMAL.xyz, vec3(0.0,0.0,1.0));
	float thickness = mix(0.0, 0.8+0.05*sin(TIME*3.0), t);
	if (d > thickness) discard;
	//if (sin(SCREEN_UV.x*50.0+SCREEN_UV.y*100.0) > 0.0) discard;
	ALBEDO = color.rgb;
	ALBEDO = vec3(DEPTH);
	
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
