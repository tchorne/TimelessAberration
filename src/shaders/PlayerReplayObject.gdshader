shader_type spatial;

render_mode unshaded;

instance uniform float fade = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
	
	VERTEX.y += sin(float(VERTEX.x*590.0+VERTEX.z*1020.0)+TIME*10.0)*0.02;
	if (fade < 1.0){
		float rand = fract(sin(float(VERTEX_ID)))*4.0f;
		rand += 0.1;
		float lerp = (pow(rand, fade)-1.0)/(rand-1.0);
		VERTEX.y = mix(0.0, VERTEX.y, min(lerp, 1.0));
	}
	
	//VERTEX.z += sin(float(VERTEX.y)+TIME*10.0)*80.0;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO.rgb = vec3(0,0,0);
	if (fade < 1.0){
		float rand = fract(sin((SCREEN_UV.x+0.5*SCREEN_UV.y)*43758.23));
		if (fade < rand) discard;
	}
	

}

void light() {
	// Called for every pixel for every light affecting the material.
}
