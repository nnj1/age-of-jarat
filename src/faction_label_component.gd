extends Node2D

@export var show_unit_faction_number: bool = true
@export var show_unit_type_sprite: bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# set initial sprite value
	if not get_parent().autonomous_mode:
		hide_computer_icon()
	
	if show_unit_faction_number:
		if 'faction' in get_parent():
			$Label.text = 'P' + str(get_parent().faction)
	if show_unit_type_sprite:
		if get_parent().is_in_group('warriors'):
			$Sprite2D.texture = preload('res://assets/cursors/kenney_cursor-pack/PNG/Outline/Default/tool_sword_b.png')
		if get_parent().is_in_group('archers'):
			$Sprite2D.texture = preload('res://assets/cursors/kenney_cursor-pack/PNG/Outline/Default/tool_bow.png')
		if get_parent().is_in_group('wizards'):
			$Sprite2D.texture = preload('res://assets/cursors/kenney_cursor-pack/PNG/Outline/Default/tool_wand.png')
		if get_parent().is_in_group('villagers'):
			$Sprite2D.texture = preload('res://assets/cursors/kenney_cursor-pack/Vector/Outline/tool_watering_can.svg')

func show_computer_icon():
	$Sprite2D2.show()
	
func hide_computer_icon():
	$Sprite2D2.hide()
