extends Node

# Define your cursor types
enum Type { DEFAULT, ATTACK, MOVE, BUILD, HOVER, CHOP, MINE, ARROW_LEFT, ARROW_RIGHT, ARROW_UP, ARROW_DOWN }

# Dictionary to map types to their texture files
# Update these paths to match your project folder!
var cursor_textures = {
	Type.DEFAULT: preload("res://assets/cursors/kenney_cursor-pack/PNG/Outline/Default/pointer_c_shaded.png"),
	Type.ATTACK:  preload("res://assets/cursors/kenney_cursor-pack/PNG/Outline/Default/tool_sword_b.png"),
	Type.MOVE:    preload("res://assets/cursors/kenney_cursor-pack/PNG/Outline/Default/resize_b_cross.png"),
	Type.BUILD:   preload("res://assets/cursors/kenney_cursor-pack/PNG/Outline/Default/tool_hammer.png"),
	Type.HOVER:   preload("res://assets/cursors/kenney_cursor-pack/PNG/Outline/Default/hand_point.png"),
	Type.CHOP:   preload("res://assets/cursors/kenney_cursor-pack/PNG/Outline/Default/tool_axe_single.png"),
	Type.MINE:   preload("res://assets/cursors/kenney_cursor-pack/PNG/Outline/Default/tool_pickaxe.png"),
	Type.ARROW_LEFT: preload("res://assets/cursors/kenney_cursor-pack/PNG/Outline/Default/arrow_w.png"),
	Type.ARROW_RIGHT: preload("res://assets/cursors/kenney_cursor-pack/PNG/Outline/Default/arrow_e.png"),
	Type.ARROW_UP: preload("res://assets/cursors/kenney_cursor-pack/PNG/Outline/Default/arrow_n.png"),
	Type.ARROW_DOWN: preload("res://assets/cursors/kenney_cursor-pack/PNG/Outline/Default/arrow_s.png")
	
}

func _ready():
	# Set the initial default cursor
	set_cursor(Type.DEFAULT)

func set_cursor(type: Type):
	if cursor_textures.has(type):
		# Input.set_custom_mouse_cursor(texture, type_of_cursor, hotspot)
		# The hotspot (Vector2.ZERO) is the "pointy" part of the cursor (top-left)
		# Use Vector2(16, 16) if you want the click point to be the center (e.g., a crosshair)
		Input.set_custom_mouse_cursor(cursor_textures[type], Input.CURSOR_ARROW, Vector2.ZERO)
	else:
		push_warning("Cursor type not found in textures dictionary.")

func reset_cursor():
	set_cursor(Type.DEFAULT)
