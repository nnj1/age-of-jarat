extends Node2D
class_name Controller

@onready var parent = get_parent()
var is_selected: bool = false

# This is called by the SelectionManager
func command_move(target_pos: Vector2):
	if is_selected and parent.has_method("set_move_target"):
		parent.set_move_target(target_pos)
		
func _draw():
	# This resets the drawing coordinate system to Global Space
	draw_set_transform(-global_position, -global_rotation, Vector2.ONE / global_scale)
		
	if is_selected:
		if get_parent().assigned_structure:
			# draw_line(from, to, color, width, antialiased)
			draw_dashed_line(get_parent().get_node('FactionLabelComponent').global_position, get_parent().assigned_structure.global_position, Color.GREEN, 1, 2)

func _process(_delta):
	# If the positions change, tell Godot to trigger _draw() again
	queue_redraw()
