extends TabContainer

func _ready() -> void:
	# Initial focus
	grab_focus()

func _gui_input(event: InputEvent) -> void:
	# Check if the Tab key (ui_focus_next) or Shift+Tab (ui_focus_prev) is pressed
	if event.is_action_pressed("ui_focus_next"):
		if has_focus():
			get_viewport().set_input_as_handled()
			_cycle_tab(1)
		else:
			grab_focus()
	
	elif event.is_action_pressed("ui_focus_prev"):
		if has_focus():
			get_viewport().set_input_as_handled()
			_cycle_tab(-1)
		else:
			grab_focus()

func _cycle_tab(direction: int) -> void:
	var total_tabs = get_tab_count()
	if total_tabs <= 1: return
	
	var next_index = current_tab
	
	for i in range(total_tabs):
		next_index = (next_index + direction + total_tabs) % total_tabs
		
		# Check if tab is hidden (Godot 4 property) or disabled
		# Note: is_tab_hidden check is safer if using set_tab_hidden()
		if not is_tab_hidden(next_index) and not is_tab_disabled(next_index):
			current_tab = next_index
			return

func _on_mouse_entered() -> void:
	CursorManager.reset_cursor()
