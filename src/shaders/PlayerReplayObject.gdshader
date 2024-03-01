shader_type spatial;

render_mode unshaded;

void vertex() {
	// Called for every vertex the material is visible on.
	
	VERTEX.y += sin(float(VERTEX.x*590.0+VERTEX.z*1020.0)+TIME*10.0)*0.02;
	//VERTEX.z += sin(float(VERTEX.y)+TIME*10.0)*80.0;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO.rgb = vec3(0,0,0);

}

void light() {
	// Called for every pixel for every light affecting the material.
}
