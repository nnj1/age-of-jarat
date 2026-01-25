extends Camera2D # Use Camera3D if your game is 3D

@export var main_camera: Camera2D
@export var minimap_zoom: float = 0.1  # Lower = More map visible

func _process(_delta):
	if main_camera:
		# Copy the position of the main camera
		global_position = main_camera.global_position
		
		# Apply the fixed zoomed-out scale
		zoom = Vector2(minimap_zoom, minimap_zoom)
