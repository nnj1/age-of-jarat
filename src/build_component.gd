extends Node2D
class_name BuildComponent

signal fully_built

@export var max_progress: float = 100.0
var current_progress: float = 0

# Reference the Sprite/Polygon instead of a ProgressBar
@onready var foreground = $BarForeground 

func _ready():
	self.modulate = Color.WHITE
	current_progress = 0
	
	_update_bar()

func set_progress(amount: float):
	if current_progress >= max_progress:
		fully_built.emit()
		
	self.modulate = Color.WHITE
	current_progress = amount
	_update_bar()
	

func _update_bar():
	# We only change the scale.x, which is extremely cheap for the GPU
	var health_pct = current_progress / max_progress
	foreground.scale.x = health_pct
	
	# Color shifting without theme overhead
	if health_pct < 0.3:
		foreground.modulate = Color.RED
	elif health_pct < 0.6:
		foreground.modulate = Color.YELLOW
	else:
		foreground.modulate = Color.GREEN
