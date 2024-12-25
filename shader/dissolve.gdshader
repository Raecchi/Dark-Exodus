shader_type spatial;

uniform float dissolve_threshold : hint_range(0.0,1.0);
uniform sampler2D noise_texture;
uniform sampler2D viewport_texture;
//uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_liear_mipmap;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV;
	float noise_value = texture(noise_texture, uv).r;
	if (noise_value < dissolve_threshold){
		discard;
	}
	COLOR = texture(viewport_texture,uv);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
