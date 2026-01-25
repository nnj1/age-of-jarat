shader_type canvas_item;

// Wind Settings
uniform float speed : hint_range(0.0, 10.0) = 2.0;
uniform float distortion : hint_range(0.0, 2.0) = 0.2;
uniform float detail : hint_range(0.0, 5.0) = 1.0;
uniform float vertical_variation : hint_range(0.0, 5.0) = 0.5;
uniform float wind_direction : hint_range(-1.0, 1.0) = 1.0;

// Transparency Settings
uniform float black_threshold : hint_range(0.0, 1.0) = 0.1;

void vertex() {
	// UV.y is 0.0 at the top and 1.0 at the bottom.
	// We want strength to be 1.0 at the top (full sway) and 0.0 at the bottom (pinned).
	float strength = (1.0 - UV.y);
	
	// Create a wave based on Time, horizontal position, and vertical position.
	// Adding (UV.y * vertical_variation) breaks the vertical sync for tall tiles.
	float wave = sin(TIME * speed + (VERTEX.x * detail) + (UV.y * vertical_variation));
	
	// Apply the movement
	// Multiplying by wind_direction allows you to control the lean.
	VERTEX.x += wave * strength * distortion * (100.0 * wind_direction);
}

void fragment() {
	// Get the pixel color from the spritesheet
	vec4 tex_color = texture(TEXTURE, UV);
	
	// Calculate brightness (average of RGB)
	float brightness = (tex_color.r + tex_color.g + tex_color.b) / 3.0;
	
	// If the pixel is darker than the threshold, delete it (discard)
	if (brightness < black_threshold) {
		discard;
	}
	
	COLOR = tex_color;
}