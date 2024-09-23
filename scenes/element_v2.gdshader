shader_type canvas_item;

uniform sampler2D tt;
uniform float progress: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float diff:hint_range(0.0, 2.0, 0.01) = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 noise_texture = texture(tt, UV);
	float xc = UV.x -0.5;
	float yc = UV.y -0.5;
	float coords = xc * xc + yc * yc;
	float threshhold = smoothstep(coords-progress*progress, noise_texture.x, 0.01);
	if (coords > progress*progress && coords + (noise_texture.x+noise_texture.x)-progress*progress  < diff)
		COLOR.a = 1.0;
	if (coords + noise_texture.x/4.0 > 1.0-progress && coords + noise_texture.x/4.0 > 1.0-progress)
		COLOR.a = 0.0;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
