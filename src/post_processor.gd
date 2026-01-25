extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	# Ensure the effect starts in a specific state
	color_rect.visible = true

func _input(event: InputEvent) -> void:
	# Check if the "toggle_post_process" action was just pressed
	if event.is_action_pressed("toggle_post_process"):
		_toggle_visibility()

func _toggle_visibility() -> void:
	color_rect.visible = !color_rect.visible
	
	# Optional: Print to console for debugging
	if color_rect.visible:
		print("Post-processing: ON")
	else:
		print("Post-processing: OFF")
