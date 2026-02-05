extends Camera2D

@export_group("Movement")
@export var speed: float = 400.0
@export var drag_sensitivity: float = 1.0

@export_group("Edge Panning")
@export var edge_pan_enabled: bool = true
@export var edge_pan_speed: float = 200.0 
@export var edge_margin: float = 40.0

@export_group("Zoom")
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5 * 4
@export var max_zoom: float = 2 * 4
@export var zoom_smoothing: float = 10.0

var _target_zoom: float = 1.0
var _is_dragging: bool = false
var _is_edge_panning: bool = false

var _mouse_inside_window: bool = true

func _notification(what):
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			_mouse_inside_window = false
			# Reset cursor and panning state immediately
			_is_edge_panning = false
			CursorManager.reset_cursor()
		NOTIFICATION_WM_MOUSE_ENTER:
			_mouse_inside_window = true

func _ready():
	_target_zoom = zoom.x

func _unhandled_input(event: InputEvent):
	# --- MIDDLE MOUSE DRAG ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				_is_dragging = true
				CursorManager.set_cursor(CursorManager.Type.MOVE)
			else:
				_is_dragging = false
				# When releasing drag, we reset. _process will pick up 
				# edge panning again if the mouse is still at the margin.
				CursorManager.reset_cursor()
				
		# --- ZOOM (SCROLL WHEEL) ---
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_zoom = clamp(_target_zoom + zoom_speed, min_zoom, max_zoom)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_zoom = clamp(_target_zoom - zoom_speed, min_zoom, max_zoom)

	if event is InputEventMouseMotion and _is_dragging:
		position -= event.relative / zoom.x * drag_sensitivity

func _process(delta: float):
	var input_dir = Vector2.ZERO
	var current_speed = speed 
	
	# Check if the mouse is over any Control node (UI)
	var is_over_gui = get_viewport().gui_get_hovered_control() != null
	
	# --- KEYBOARD INPUT ---
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# --- EDGE PANNING & CURSOR LOGIC ---
	if edge_pan_enabled and not _is_dragging and not is_over_gui and _mouse_inside_window:
		var mouse_pos = get_viewport().get_mouse_position()
		var screen_size = get_viewport().get_visible_rect().size
		var edge_dir = Vector2.ZERO
		
		# Determine Direction
		if mouse_pos.x < edge_margin:
			edge_dir.x = -1
		elif mouse_pos.x > screen_size.x - edge_margin:
			edge_dir.x = 1
			
		if mouse_pos.y < edge_margin:
			edge_dir.y = -1
		elif mouse_pos.y > screen_size.y - edge_margin:
			edge_dir.y = 1
		
		# Update Cursor based on Direction
		_update_edge_cursor(edge_dir)
		
		# Apply movement if no keyboard input is overriding
		if edge_dir != Vector2.ZERO and input_dir == Vector2.ZERO:
			input_dir = edge_dir
			current_speed = edge_pan_speed

	# --- MOVEMENT EXECUTION ---
	if input_dir != Vector2.ZERO:
		position += input_dir.normalized() * (current_speed / zoom.x) * delta

	# --- SMOOTH ZOOM ---
	if not is_equal_approx(zoom.x, _target_zoom):
		var zoom_val = lerp(zoom.x, _target_zoom, zoom_smoothing * delta)
		zoom = Vector2(zoom_val, zoom_val)

## Private helper to handle directional cursor switching
func _update_edge_cursor(edge_dir: Vector2) -> void:
	if edge_dir != Vector2.ZERO:
		_is_edge_panning = true
		
		# Check for specific directions. 
		# Adjust the CursorManager.Type names to match your actual Autoload.
		match edge_dir:
			Vector2(-1, 0): CursorManager.set_cursor(CursorManager.Type.ARROW_LEFT)
			Vector2(1, 0):  CursorManager.set_cursor(CursorManager.Type.ARROW_RIGHT)
			Vector2(0, -1): CursorManager.set_cursor(CursorManager.Type.ARROW_UP)
			Vector2(0, 1):  CursorManager.set_cursor(CursorManager.Type.ARROW_DOWN)
			_:              CursorManager.set_cursor(CursorManager.Type.MOVE) # Covers diagonals
	else:
		# If we were edge panning but aren't anymore, reset once.
		if _is_edge_panning:
			_is_edge_panning = false
			CursorManager.reset_cursor()

func center_on_position(target_pos: Vector2):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_pos, 0.5)
