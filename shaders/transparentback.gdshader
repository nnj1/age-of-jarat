shader_type canvas_item;

// Your Transparency Logic
uniform float threshold : hint_range(0.0, 1.0) = 0.1;
uniform float edge_distance : hint_range(0.0, 1.0) = 0.4;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    float dist = distance(UV, vec2(0.5, 0.5));
    
    if (color.r < threshold && color.g < threshold && color.b < threshold) {
        if (dist > edge_distance) {
            color.a = 0.0;
        }
    }
    COLOR = color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
