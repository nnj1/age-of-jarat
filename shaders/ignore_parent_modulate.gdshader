shader_type canvas_item;

// This boolean allows you to toggle the protection on/off from the inspector
uniform bool ignore_parent_modulate = true;

void fragment() {
    // Read the texture color as usual
    vec4 tex_color = texture(TEXTURE, UV);
    
    if (ignore_parent_modulate) {
        // COLOR is the final output. 
        // By assigning tex_color directly, we ignore the 'MODULATE' 
        // variable that Godot usually multiplies behind the scenes.
        COLOR = tex_color;
    } else {
        // Normal behavior
        COLOR = tex_color * COLOR;
    }
}