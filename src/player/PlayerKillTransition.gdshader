shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D mask : repeat_enable;
uniform float t = 0.0;
uniform float slice = 0.0;

void fragment() {
	// Called for every pixel the material is visible on.
	//COLOR = textureLod(screen_texture, SCREEN_UV, 0.0);
	
	//float maskVal = texture(mask, SCREEN_UV, 0.0).r;
	float rand = 1.0;
	if (t > 0.0){
		rand = fract(sin(SCREEN_UV.y*49254.43));
	}
	if (rand > t){
		if (SCREEN_UV.y > 0.5){
			COLOR = textureLod(screen_texture, SCREEN_UV+vec2(slice, 0), 0.0);
		} else {
			COLOR = textureLod(screen_texture, SCREEN_UV-vec2(slice, 0), 0.0);
		}
	} else {
		COLOR.rgb = vec3(0);
	}
	
	
	
	//COLOR.rgb = vec3(0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
