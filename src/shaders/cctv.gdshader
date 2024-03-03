shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

void vertex() {
	// Called for every vertex the material is visible on.
}

float random (vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898,783.233))) * 4358.5453123 * TIME);
}

vec3 greyscale(vec3 col){
	return vec3(0.2*col.r + 0.7*col.g + 0.1*col.b);
}
void fragment() {
	
	float noise = random(SCREEN_UV);
	
	vec3 col = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	COLOR.rgb = mix(col, greyscale(col), 0.5);
	COLOR.rgb += vec3(noise)*0.2;
		
}