shader_type canvas_item;

uniform vec2 size = vec2(192.0, 48.0); 
uniform vec2 offset = vec2(0.0, 0.0);   
uniform float radius = 10.0;           

varying vec2 local_pos;

void vertex() {
    local_pos = VERTEX;
}

void fragment() {
    // Determine the center based on the size and offset provided by the script
    vec2 center = offset + (size * 0.5);
    
    // Calculate distance to the rounded edge
    vec2 q = abs(local_pos - center) - (size * 0.5) + radius;
    float dist = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
    
    // Generate the alpha mask with anti-aliasing
    float soft_edge = fwidth(dist);
    float alpha = 1.0 - smoothstep(-soft_edge, soft_edge, dist);
    
    // Pull the color from the Polygon2D 'Color' property and/or its 'Texture'
    vec4 final_color = texture(TEXTURE, UV) * COLOR;
    
    // Apply the rounded mask to the existing alpha channel
    COLOR = vec4(final_color.rgb, final_color.a * alpha);
}