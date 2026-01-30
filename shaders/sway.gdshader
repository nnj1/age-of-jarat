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
    // 1. Get the raw texture color FIRST
    vec4 raw_tex = texture(TEXTURE, UV);
    
    // 2. Check brightness of the RAW texture (ignoring modulation)
    float brightness = (raw_tex.r + raw_tex.g + raw_tex.b) / 3.0;
    
    // 3. If the RAW pixel is dark, discard it
    if (brightness < black_threshold) {
        discard;
    }
    
    // 4. NOW apply the modulation (COLOR) to the result
    COLOR = raw_tex * COLOR;
}