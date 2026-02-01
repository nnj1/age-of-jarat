shader_type canvas_item;

uniform vec4 border_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float thickness_pixels = 20.0; // Set this high (e.g., 50.0) to test!

void fragment() {
	// SCREEN_PIXEL_SIZE gives us (1/width, 1/height) of the viewport
	// We multiply UV by the total resolution to get current pixel coordinates
	vec2 screen_res = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 pixel_pos = UV * screen_res;
	
	// Check if the current pixel is within X pixels of any edge
	bool left   = pixel_pos.x < thickness_pixels;
	bool right  = pixel_pos.x > screen_res.x - thickness_pixels;
	bool top    = pixel_pos.y < thickness_pixels;
	bool bottom = pixel_pos.y > screen_res.y - thickness_pixels;
	
	if (left || right || top || bottom) {
		COLOR = border_color;
	} else {
		// Makes the center transparent so you can see your game
		discard; 
	}
}