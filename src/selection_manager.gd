extends Node2D

@onready var main_game_node = get_tree().get_root().get_node('Game')

# Selection variables
var dragging = false
var selected_units = []
signal selected_units_changed
signal unit_just_added
var drag_start = Vector2.ZERO
var drag_end = Vector2.ZERO

# Control Group storage (stores unit arrays mapped to keycodes)
var control_groups = {} 

func spawn_walk_indicator(pos: Vector2):
	var instance = preload('res://scenes/components/ClickIndicator.tscn').instantiate()
	add_child(instance)
	instance.global_position = pos

func _unhandled_input(event):
	# --- LEFT CLICK: SELECTION LOGIC ---
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var shift = Input.is_key_pressed(KEY_SHIFT)
		
		if event.pressed:
			dragging = true
			drag_start = get_global_mouse_position()
			# Only clear selection if we aren't holding shift
			if not shift:
				deselect_all()
		else:
			dragging = false
			var drag_dist = drag_start.distance_to(get_global_mouse_position())
			
			if drag_dist < 10: # Threshold for a single click
				handle_single_selection(get_global_mouse_position(), shift)
			else: # Drag box finished
				select_units_in_box(shift)
			queue_redraw()

	if event is InputEventMouseMotion and dragging:
		drag_end = get_global_mouse_position()
		queue_redraw()

	# --- RIGHT CLICK: MOVEMENT COMMAND ---
	if event.is_action_pressed("mouse_right_click") and selected_units.size() > 0:
		var target = get_global_mouse_position()
		for i in range(selected_units.size()):
			# Basic spread so they don't all overlap at the exact same pixel
			var offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
			var unit = selected_units[i]
			
			# Access the component we renamed to UnitController
			if unit:
				var controller = unit.get_node_or_null("UnitController")
				if controller:
					controller.command_move(target + offset)
					spawn_walk_indicator(get_global_mouse_position())

	# --- KEYBOARD: CONTROL GROUPS ---
	if event is InputEventKey and event.pressed:
		# Deselect all on Escape
		if event.keycode == KEY_ESCAPE:
			deselect_all()
			
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_0 and event.keycode <= KEY_9:
			if Input.is_key_pressed(KEY_CTRL):
				save_control_group(event.keycode)
			else:
				load_control_group(event.keycode)
	
func _process(_delta: float) -> void:
	# spacebar camera centering
	if Input.is_action_pressed("ui_select"): # "ui_select" is Spacebar by default
		center_camera_on_selection()

func center_camera_on_selection():
	if selected_units.is_empty():
		return
		
	var total_position = Vector2.ZERO

	var valid_unit_count = 0
	
	for unit in selected_units:
		if is_instance_valid(unit):
			total_position += unit.global_position
			valid_unit_count += 1
			
	if valid_unit_count > 0:
		var center_point = total_position / valid_unit_count
		
		# Find the camera in the scene tree and tell it to move
		# We use get_viewport().get_camera_2d() to find the active camera
		var camera = get_viewport().get_camera_2d()
		if camera and camera.has_method("center_on_position"):
			camera.center_on_position(center_point)

func _draw():
	if dragging:
		var rect = Rect2(drag_start, drag_end - drag_start)
		# Green for standard, Red for Shift-selection
		var color = Color(0, 1, 0, 0.2) if not Input.is_key_pressed(KEY_SHIFT) else Color(1, 0, 1, 0.2)
		draw_rect(rect, color, true)
		draw_rect(rect, color.lightened(0.4), false, 2.0)

# --- HELPER FUNCTIONS ---

func handle_single_selection(click_pos: Vector2, shift: bool):
	var all_units = get_tree().get_nodes_in_group("units")
	var closest_unit = null
	var min_dist = 5.0 # Interaction radius

	for unit in all_units:
		var dist = unit.global_position.distance_to(click_pos)
		if dist < min_dist:
			min_dist = dist
			closest_unit = unit
	
	if closest_unit:
		if shift and selected_units.has(closest_unit):
			remove_from_selection(closest_unit)
		else:
			add_to_selection(closest_unit)

func select_units_in_box(_shift: bool):
	var box = Rect2(drag_start, drag_end - drag_start).abs()
	for unit in get_tree().get_nodes_in_group("units"):
		if box.has_point(unit.global_position):
			add_to_selection(unit)

func add_to_selection(unit):
	
	# This was the last unit added to the selection, show it's details in the UI
	unit_just_added.emit(unit)
	
	if not selected_units.has(unit):
		selected_units.append(unit)
		unit.set_selected(true)
	
	selected_units_changed.emit(selected_units)

func remove_from_selection(unit):
	selected_units.erase(unit)
	unit.set_selected(false)
	selected_units_changed.emit(selected_units)

func deselect_all():
	for unit in selected_units:
		if is_instance_valid(unit):
			unit.set_selected(false)
	selected_units.clear()
	selected_units_changed.emit(selected_units)
	
# --- CONTROL GROUP LOGIC ---
func save_control_group(key):
	control_groups[key] = selected_units.duplicate()
	# Optional: Feedback log (e.g., "Group 1 Saved")
	print("Group ", key - 48, " saved.") 

func load_control_group(key):
	if control_groups.has(key):
		deselect_all()
		for unit in control_groups[key]:
			if is_instance_valid(unit): # Ensure unit hasn't been deleted/destroyed
				add_to_selection(unit)
