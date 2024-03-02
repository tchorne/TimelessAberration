shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D mask : repeat_enable;
uniform float t = 0.0;

void fragment() {
	// Called for every pixel the material is visible on.
	//COLOR = textureLod(screen_texture, SCREEN_UV, 0.0);
	COLOR = texture(mask, SCREEN_UV, 0.0);
	if (COLOR.r > t) discard;
	COLOR.rgb = vec3(0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
