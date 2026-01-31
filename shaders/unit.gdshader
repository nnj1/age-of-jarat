shader_type canvas_item;

varying vec2 local_uv; 

// --- Bounce & Deformation ---
uniform float random_phase;
uniform float speed : hint_range(0.1, 10.0) = 5.0;
uniform float height : hint_range(0.0, 100.0) = 0.0;
uniform float squash_amount : hint_range(0.0, 0.5) = 0.024;
uniform float sprite_height = 12.0;

// --- Transparency Logic ---
// This now controls how "pure black" a pixel must be to vanish.
// Set this to a small value (like 0.1)
uniform float black_sensitivity : hint_range(0.0, 1.0) = 0.1;
uniform float edge_distance : hint_range(0.0, 1.0) = 0.05;

// --- Border Controls ---
uniform bool use_active_state = false;
uniform vec4 default_border_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 active_border_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float default_border_width : hint_range(0.0, 10.0) = 0.5;
uniform float active_border_width : hint_range(0.0, 10.0) = 0.25;

uniform float glow_intensity : hint_range(1.0, 10.0) = 1.0;

float get_shape_alpha(sampler2D tex, vec2 uv, vec2 l_uv) {
    vec4 tex_color = texture(tex, uv);
    float dist = distance(l_uv, vec2(0.5, 0.5));
    
    // NEW LOGIC: Check how far the color is from PURE BLACK
    // distance(RGB, Black) will be large for Gray/Yellow, but small for Black.
    float dist_from_black = distance(tex_color.rgb, vec3(0.0));
    
    // If it's very close to black AND far from center, kill it.
    if (dist_from_black < black_sensitivity && dist > edge_distance) {
        return 0.0;
    }
    return tex_color.a;
}

void vertex() {
    local_uv = UV;
    float time = (TIME + random_phase) * speed;
    float bounce_cycle = abs(sin(time)); 
    float squash_cycle = cos(time * 2.0); 
    
    float squash_factor = 1.0 + (squash_cycle * squash_amount);
    VERTEX.x *= (1.0 + (squash_cycle * -squash_amount));
    VERTEX.y *= squash_factor;

    float center_to_bottom = sprite_height / 2.0;
    float correction = (center_to_bottom * squash_factor) - center_to_bottom;
    VERTEX.y -= correction;
    VERTEX.y -= bounce_cycle * height;
}

void fragment() {
    vec4 tex_raw = texture(TEXTURE, UV);
    float current_a = get_shape_alpha(TEXTURE, UV, local_uv);
    
    vec4 b_color = use_active_state ? active_border_color : default_border_color;
    float b_width = use_active_state ? active_border_width : default_border_width;
    
    vec4 final_color = vec4(0.0);

    if (current_a > 0.0) {
        // Draw the actual sprite (Grays and Yellows will now stay intact)
        final_color = vec4(tex_raw.rgb, current_a);
    } else if (b_color.a > 0.0) {
        // Draw the border
        vec2 size = TEXTURE_PIXEL_SIZE * b_width;
        float na = 0.0;
        na += get_shape_alpha(TEXTURE, UV + vec2(0.0, -size.y), local_uv + vec2(0.0, -size.y));
        na += get_shape_alpha(TEXTURE, UV + vec2(0.0, size.y), local_uv + vec2(0.0, size.y));
        na += get_shape_alpha(TEXTURE, UV + vec2(-size.x, 0.0), local_uv + vec2(-size.x, 0.0));
        na += get_shape_alpha(TEXTURE, UV + vec2(size.x, 0.0), local_uv + vec2(size.x, 0.0));
        
        if (na > 0.0) {
            final_color = b_color;
        }
    }

    COLOR = vec4(final_color.rgb * glow_intensity, final_color.a);
}