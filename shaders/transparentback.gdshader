shader_type canvas_item;

uniform float threshold : hint_range(0.0, 1.0) = 0.1;
uniform float edge_distance : hint_range(0.0, 1.0) = 0.4;

void fragment() {
    // 1. Get the original color from the texture
    vec4 tex_color = texture(TEXTURE, UV);

    // 2. Get the distance from the center
    float dist = distance(UV, vec2(0.5));

    // 3. Create a mask based on your "black" threshold
    // We check if the pixel is darker than the threshold
    bool is_black = (tex_color.r < threshold && tex_color.g < threshold && tex_color.b < threshold);

    // 4. Initialize our final alpha
    float final_alpha = tex_color.a;

    // 5. Apply transparency logic
    if (is_black && dist > edge_distance) {
        final_alpha = 0.0;
    }

    // 6. Output: Multiply the original texture color by any vertex color/modulate
    // and apply our new alpha.
    COLOR = vec4(tex_color.rgb, final_alpha) * COLOR;
}