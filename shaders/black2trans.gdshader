shader_type canvas_item;

// Individual Variation
uniform float random_phase; // Set this via GDScript

// Bounce & Deformation
uniform float speed : hint_range(0.1, 10.0) = 3.0;
uniform float height : hint_range(0.0, 100.0) = 20.0;
uniform float squash_amount : hint_range(0.0, 0.5) = 0.2;
uniform float sprite_height = 12.0;

// Your Transparency Logic
uniform float threshold : hint_range(0.0, 1.0) = 0.1;
uniform float edge_distance : hint_range(0.0, 1.0) = 0.4;

void vertex() {
    // 1. Use the uniform for stable, unique timing
    float time = (TIME + random_phase) * speed;
    
    float bounce_cycle = abs(sin(time)); 
    float squash_cycle = cos(time * 2.0); 
    
    // 2. Scale Math (Squash and Stretch)
    float squash_factor = 1.0 + (squash_cycle * squash_amount);
    VERTEX.x *= (1.0 + (squash_cycle * -squash_amount));
    VERTEX.y *= squash_factor;

    // 3. Pin Feet Math (Counteracting centered pivot)
    float center_to_bottom = sprite_height / 2.0;
    float correction = (center_to_bottom * squash_factor) - center_to_bottom;
    VERTEX.y -= correction;

    // 4. Apply the Jump
    VERTEX.y -= bounce_cycle * height;
}

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