shader_type canvas_item;

// Variables to control from the Inspector
uniform vec3 fog_color : source_color = vec3(0.5, 0.6, 0.7);
uniform float density : hint_range(0.0, 1.0) = 0.5;
uniform float speed : hint_range(0.0, 5.0) = 1.0;
uniform int octaves = 4;

// Random noise function
float rand(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Simple Value Noise
float noise(vec2 uv) {
	vec2 i = floor(uv);
	vec2 f = fract(uv);
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fractal Brownian Motion for layered organic look
float fbm(vec2 uv) {
	float value = 0.0;
	float amplitude = 0.5;
	for (int i = 0; i < octaves; i++) {
		value += amplitude * noise(uv);
		uv *= 2.0;
		amplitude *= 0.5;
	}
	return value;
}

void fragment() {
	// Scroll the UVs over time to create movement
	vec2 motion = vec2(TIME * 0.1 * speed, TIME * 0.05 * speed);
	
	// Generate the noise value
	float fog_factor = fbm(UV * 3.0 + motion);
	
	// Apply density and edge fade
	float alpha = clamp(fog_factor * density, 0.0, 1.0);
	
	// Output the final color with the calculated alpha
	COLOR = vec4(fog_color, alpha);
}