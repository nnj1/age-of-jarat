shader_type canvas_item;

uniform float speed : hint_range(0.0, 5.0) = 1.0;
uniform float wave_intensity : hint_range(0.0, 0.1) = 0.02;
uniform float wave_frequency : hint_range(0.0, 0.1) = 0.05;

uniform float distortion_strength : hint_range(0.0, 0.1) = 0.01;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform float water_opacity : hint_range(0.0, 1.0) = 0.6;
uniform float black_threshold : hint_range(0.0, 1.0) = 0.1;

// This will force the blue to be light and bright
uniform float glow_power : hint_range(1.0, 10.0) = 4.0;
uniform vec4 light_blue_tint : source_color = vec4(0.4, 0.7, 1.0, 1.0);

void vertex() {
	vec2 world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	float wave = sin(TIME * speed + (world_pos.x * wave_frequency) + (world_pos.y * wave_frequency));
	VERTEX.y += wave * (wave_intensity * 100.0);
	VERTEX.x += wave * (wave_intensity * 50.0);
}

void fragment() {
	vec4 modulation = COLOR;
	vec4 tex_color = texture(TEXTURE, UV);

	// 1. Transparency Check
	if (tex_color.a < 0.1 || (tex_color.r + tex_color.g + tex_color.b) / 3.0 < black_threshold) {
		discard;
	}

	// 2. Distortion
	vec2 distorted_uv = SCREEN_UV + sin(TIME * speed + (UV.x * 10.0) + (UV.y * 10.0)) * distortion_strength;
	vec3 background_color = texture(screen_texture, distorted_uv).rgb;

	// 3. THE "BRIGHTENER" MATH
	// Instead of multiplying, we use the texture's brightness to "emit" the light blue.
	// We add modulation and our light_blue_tint together.
	float tex_brightness = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));

	// This creates a "Light Blue" base that ignores the dark tile color
	vec3 glow_base = light_blue_tint.rgb * modulation.rgb * glow_power;

	// Mix the original texture slightly but let the glow dominate
	vec3 water_layer = mix(glow_base, glow_base + tex_color.rgb, 0.3);

	// 4. Final Mix
	vec3 final_rgb = mix(background_color, water_layer, water_opacity);

	// Ensure the alpha from modulation still works
	COLOR = vec4(final_rgb, modulation.a * tex_color.a);
}