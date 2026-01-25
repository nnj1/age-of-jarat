extends Node
class_name Controller

@onready var parent = get_parent()
var is_selected: bool = false

# This is called by the SelectionManager
func command_move(target_pos: Vector2):
	if is_selected and parent.has_method("set_move_target"):
		parent.set_move_target(target_pos)
