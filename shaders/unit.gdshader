shader_type canvas_item;

varying vec2 local_uv; 

// --- Bounce & Deformation ---
uniform float random_phase;
uniform float speed : hint_range(0.1, 10.0) = 5.0;
uniform float height : hint_range(0.0, 100.0) = 0.0;
uniform float squash_amount : hint_range(0.0, 0.5) = 0.024;
uniform float sprite_height = 12.0;

// --- Transparency Logic ---
uniform float threshold : hint_range(0.0, 1.0) = 0.1;
uniform float edge_distance : hint_range(0.0, 1.0) = 0.055;

// --- Border Controls ---
uniform bool use_active_state = false;
uniform vec4 default_border_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 active_border_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float default_border_width : hint_range(0.0, 10.0) = 0.5;
uniform float active_border_width : hint_range(0.0, 10.0) = 0.25;

float get_shape_alpha(sampler2D tex, vec2 uv, vec2 l_uv) {
    vec4 tex_color = texture(tex, uv);
    float dist = distance(l_uv, vec2(0.5, 0.5));
    float brightness = (tex_color.r + tex_color.g + tex_color.b) / 3.0;
    
    if (brightness < threshold && dist > edge_distance) {
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
    vec4 color = texture(TEXTURE, UV);
    float current_a = get_shape_alpha(TEXTURE, UV, local_uv);
    color.a = current_a;

    // Determine color AND width based on the active state
    vec4 final_border_color = use_active_state ? active_border_color : default_border_color;
    float final_width = use_active_state ? active_border_width : default_border_width;

    // Border Logic
    if (final_border_color.a > 0.0 && current_a <= 0.0) {
        vec2 size = TEXTURE_PIXEL_SIZE * final_width;
        
        float neighbor_a = 0.0;
        neighbor_a += get_shape_alpha(TEXTURE, UV + vec2(0.0, -size.y), local_uv + vec2(0.0, -size.y));
        neighbor_a += get_shape_alpha(TEXTURE, UV + vec2(0.0, size.y), local_uv + vec2(0.0, size.y));
        neighbor_a += get_shape_alpha(TEXTURE, UV + vec2(-size.x, 0.0), local_uv + vec2(-size.x, 0.0));
        neighbor_a += get_shape_alpha(TEXTURE, UV + vec2(size.x, 0.0), local_uv + vec2(size.x, 0.0));
        
        if (neighbor_a > 0.0) {
            color = final_border_color;
        }
    }

    COLOR = color;
}