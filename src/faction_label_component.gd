extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if 'faction' in get_parent():
		$Label.text = 'P' + str(get_parent().faction)
	if get_parent().is_in_group('warriors'):
		$Sprite2D.texture = preload('res://assets/cursors/kenney_cursor-pack/PNG/Outline/Default/tool_sword_b.png')
	if get_parent().is_in_group('archers'):
		$Sprite2D.texture = preload('res://assets/cursors/kenney_cursor-pack/PNG/Outline/Default/tool_bow.png')
	if get_parent().is_in_group('wizards'):
		$Sprite2D.texture = preload('res://assets/cursors/kenney_cursor-pack/PNG/Outline/Default/tool_wand.png')
	if get_parent().is_in_group('villagers'):
		$Sprite2D.texture = preload('res://assets/cursors/kenney_cursor-pack/Vector/Outline/tool_watering_can.svg')
