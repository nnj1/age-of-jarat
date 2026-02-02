shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.5;
uniform float thickness : hint_range(0.0, 0.5) = 0.05;
uniform float radius : hint_range(0.0, 0.5) = 0.4;
uniform vec4 color : source_color = vec4(1.0);

void fragment() {
    vec2 uv = UV - 0.5;
    float dist = length(uv);

    // Calculate angle (0.0 to 1.0)
    // + 0.75 starts the fill at the top (12 o'clock)
    float angle = fract((atan(uv.y, uv.x) / (2.0 * PI)) + 0.75);

    // SHARP RING:
    // This checks if the distance is within the thickness range.
    // We use a very small epsilon (0.001) to keep it crisp but avoid "shimmering".
    float outer_edge = step(dist, radius + (thickness * 0.5));
    float inner_edge = step(dist, radius - (thickness * 0.5));
    float ring = outer_edge - inner_edge;

    // SHARP MASK:
    // Using step() here ensures the progress cut is a perfectly hard line.
    float mask = step(angle, progress);

    COLOR = vec4(color.rgb, ring * mask * color.a);
}