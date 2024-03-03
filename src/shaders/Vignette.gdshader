shader_type canvas_item;

uniform sampler2D text;
uniform float t;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float val = texture(text, SCREEN_UV).r;
	COLOR.a = (1.0-val)*t;
	COLOR.rgb = vec3(0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
