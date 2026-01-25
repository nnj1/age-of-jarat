shader_type canvas_item;

// Motion Settings
uniform float speed : hint_range(0.0, 5.0) = 1.0;
uniform float wave_intensity : hint_range(0.0, 0.1) = 0.02;
uniform float wave_frequency : hint_range(0.0, 0.1) = 0.05;

// Refraction/Distortion Settings
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.01;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// Color & Transparency Settings
uniform vec4 water_color : source_color = vec4(0.2, 0.5, 0.9, 1.0);
uniform float water_opacity : hint_range(0.0, 1.0) = 0.6;
uniform float black_threshold : hint_range(0.0, 1.0) = 0.1;

void vertex() {
	vec2 world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	float wave = sin(TIME * speed + (world_pos.x * wave_frequency) + (world_pos.y * wave_frequency));

	VERTEX.y += wave * (wave_intensity * 100.0);
	VERTEX.x += wave * (wave_intensity * 50.0);
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	// 1. Transparency Check for black backgrounds
	float brightness = (tex_color.r + tex_color.g + tex_color.b) / 3.0;
	if (brightness < black_threshold) {
		discard;
	}

	// 2. Calculate Distortion for the background
	// We use a sine wave to offset the SCREEN_UV (the coordinates of the screen pixels)
	vec2 distorted_uv = SCREEN_UV + sin(TIME * speed + (UV.x * 10.0) + (UV.y * 10.0)) * distortion_strength;

	// 3. Grab the distorted background color
	vec3 background_color = texture(screen_texture, distorted_uv).rgb;

	// 4. Mix the water texture, the tint, and the background
	vec3 tinted_water = mix(tex_color.rgb, water_color.rgb, 0.5);
	vec3 final_rgb = mix(background_color, tinted_water, water_opacity);

	COLOR = vec4(final_rgb, 1.0); // We keep alpha 1.0 because we manually mixed the background in
}