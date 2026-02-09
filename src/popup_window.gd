extends Control

@export var contents_bb_code: String = '\n\n'.join(GlobalVars.lore.world_history)
@export var window_title: String = 'Lore'

# Dragging variables
var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

@onready var header = $Panel/VBoxContainer/HBoxContainer/window_title

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel/VBoxContainer/HBoxContainer/window_title.text = window_title
	$Panel/VBoxContainer/RichTextLabel.text = contents_bb_code
	
	# Connect the gui_input signal of the header via code 
	# (or do it in the editor UI)
	header.gui_input.connect(_on_header_gui_input)

func _on_header_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			# Calculate the distance between the mouse and the top-left of the window
			drag_offset = get_global_mouse_position() - global_position
			
	if event is InputEventMouseMotion and dragging:
		# Update window position based on mouse movement
		global_position = get_global_mouse_position() - drag_offset

func _on_button_pressed() -> void:
	queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_cancel'):
		get_viewport().set_input_as_handled()
		queue_free()
